


## 🎯 Overview

The Payment & Wallet system enables shops to receive payments from customers via integrated providers (Paystack for African markets, Stripe Connect for international markets), manages shop wallets for earnings, handles withdrawals, processes platform fees, and ensures idempotent transaction processing. It includes Edge Functions for provider-specific operations and automatic withdrawal processing.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 3 (Booking System)

## 🏗️ Core Decisions

### 1. Dual Payment Provider Architecture

**Decision**: Support both Paystack (African markets) and Stripe Connect (international)

**Why**:

- Paystack specializes in African payment methods (mobile money, bank transfers)
- Stripe Connect handles international cards and global markets
- Shop owners choose provider based on their currency and location
- Platform collects fees regardless of provider

### 2. Edge Functions for Provider Integration

**Decision**: Supabase Edge Functions for payment provider API calls

**Why**:

- Keeps API keys secure (not in client)
- Handles OAuth flows safely
- Manages webhook processing
- Centralizes provider-specific logic

### 3. Wallet-Based Earnings System

**Decision**: Each shop has a wallet for accumulated earnings

**Why**:

- Separates customer payments from shop payouts
- Enables holding deposits until service completion
- Supports multiple transaction types
- Facilitates refunds and adjustments

### 4. Idempotent Withdrawals

**Decision**: Unique keys prevent duplicate withdrawal requests

**Why**:

- Prevents double payouts from retry scenarios
- Uses database constraints for enforcement
- Maintains pending withdrawals tracking

### 5. Automated Withdrawal Processing

**Decision**: Database webhook triggers Edge Function for withdrawals

**Why**:

- Immediate processing without user waiting
- No scheduled jobs to maintain
- Retry logic for failed transfers
- Refunds wallet on failure

## 📊 Data Models

**Location**: `lib/features/shops/payment/data/models/` and `lib/features/shops/wallet/data/models/`

| Model                           | Purpose                                                                                  |
| ------------------------------- | ---------------------------------------------------------------------------------------- |
| `payment_settings_model.dart`   | Shop payment provider configuration, subaccount codes, verification status               |
| `wallet_model.dart`             | Shop wallet balance, pending withdrawals, total earned/withdrawn/fees                    |
| `wallet_transaction_model.dart` | Individual transaction with type (deposit, withdrawal, refund, platform_fee, adjustment) |
| `withdrawal_request_model.dart` | Withdrawal record with amount, fee (2%), status (pending/processing/completed/failed)    |

## 🗄️ Database Schema

### Payment Settings Table

```sql
CREATE TABLE payment_settings (
  shop_id UUID PRIMARY KEY REFERENCES shops(id) ON DELETE CASCADE,
  payment_provider TEXT,
  paystack_subaccount_code TEXT,
  paystack_recipient_id TEXT,
  paystack_recipient_verified BOOLEAN DEFAULT false,
  paystack_verified BOOLEAN DEFAULT false,
  paystack_currency TEXT,
  stripe_account_id TEXT,
  stripe_verified BOOLEAN DEFAULT false,
  stripe_currency TEXT,
  auto_payout_enabled BOOLEAN DEFAULT true,
  payout_schedule TEXT DEFAULT 'weekly',
  payout_minimum DECIMAL(10,2) DEFAULT 50.00,
  payout_currency TEXT DEFAULT 'GHS',
  connected_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_provider CHECK (payment_provider IN ('paystack', 'stripe', NULL))
);

CREATE INDEX idx_payment_settings_provider ON payment_settings(payment_provider);
```

### Wallets Table

```sql
CREATE TABLE wallets (
  shop_id UUID PRIMARY KEY REFERENCES shops(id) ON DELETE CASCADE,
  balance DECIMAL(10,2) NOT NULL DEFAULT 0,
  pending_withdrawals DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_earned DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_withdrawn DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_fees DECIMAL(10,2) NOT NULL DEFAULT 0,
  last_transaction_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT balance_non_negative CHECK (balance >= 0),
  CONSTRAINT pending_withdrawals_non_negative CHECK (pending_withdrawals >= 0)
);
```

### Wallet Transactions Table

```sql
CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES wallets(shop_id) NOT NULL,
  type TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  balance_after DECIMAL(10,2) NOT NULL,
  reference TEXT,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_type CHECK (type IN ('deposit', 'service_payment', 'withdrawal', 'refund', 'platform_fee', 'adjustment'))
);

CREATE INDEX idx_wallet_transactions_shop_id ON wallet_transactions(shop_id);
CREATE INDEX idx_wallet_transactions_reference ON wallet_transactions(reference);
```

### Withdrawal Requests Table

```sql
CREATE TABLE withdrawal_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES wallets(shop_id) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  fee DECIMAL(10,2) NOT NULL,
  net_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  provider TEXT,
  provider_transfer_id TEXT,
  failure_reason TEXT,
  idempotency_key TEXT UNIQUE,
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  CONSTRAINT min_withdrawal CHECK (amount >= 50)
);

CREATE INDEX idx_withdrawal_requests_shop_id ON withdrawal_requests(shop_id);
CREATE INDEX idx_withdrawal_requests_idempotency_key ON withdrawal_requests(idempotency_key);
```

### Atomic Withdrawal Function

```sql
CREATE OR REPLACE FUNCTION create_withdrawal_request(
  p_shop_id UUID, p_amount DECIMAL(10,2), p_idempotency_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_wallet wallets%ROWTYPE;
  v_fee DECIMAL(10,2);
  v_net_amount DECIMAL(10,2);
  v_withdrawal_id UUID;
BEGIN
  -- Check idempotency
  SELECT id INTO v_withdrawal_id FROM withdrawal_requests
  WHERE idempotency_key = p_idempotency_key;
  IF FOUND THEN
    RETURN jsonb_build_object('withdrawal_id', v_withdrawal_id, 'is_existing', true);
  END IF;

  -- Lock wallet row for update
  SELECT * INTO v_wallet FROM wallets WHERE shop_id = p_shop_id FOR UPDATE;

  -- Validate withdrawal amount
  IF v_wallet.balance - v_wallet.pending_withdrawals < p_amount THEN
    RAISE EXCEPTION 'Insufficient available balance';
  END IF;

  -- Calculate fee (2%, minimum GHS 1)
  v_fee := GREATEST(p_amount * 0.02, 1);
  v_net_amount := p_amount - v_fee;

  -- Create withdrawal request
  INSERT INTO withdrawal_requests (shop_id, amount, fee, net_amount, idempotency_key)
  VALUES (p_shop_id, p_amount, v_fee, v_net_amount, p_idempotency_key)
  RETURNING id INTO v_withdrawal_id;

  -- Update wallet pending withdrawals
  UPDATE wallets SET pending_withdrawals = pending_withdrawals + p_amount, updated_at = NOW()
  WHERE shop_id = p_shop_id;

  -- Record transaction
  INSERT INTO wallet_transactions (shop_id, type, amount, balance_after, reference)
  VALUES (p_shop_id, 'withdrawal', -p_amount, v_wallet.balance - p_amount, v_withdrawal_id::TEXT);

  RETURN jsonb_build_object('withdrawal_id', v_withdrawal_id, 'fee', v_fee, 'net_amount', v_net_amount, 'is_existing', false);
END;
$$;
```

### Booking Completion Payment Function

```sql
CREATE OR REPLACE FUNCTION complete_booking_payment(p_booking_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_booking bookings%ROWTYPE;
  v_remaining_amount DECIMAL(10,2);
  v_platform_fee DECIMAL(10,2);
  v_shop_net DECIMAL(10,2);
  v_shop_id UUID;
BEGIN
  SELECT * INTO v_booking FROM bookings WHERE id = p_booking_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Booking not found'; END IF;

  IF v_booking.status NOT IN ('pending', 'confirmed') THEN
    RAISE EXCEPTION 'Booking cannot be completed';
  END IF;

  SELECT shop_id INTO v_shop_id FROM bookings WHERE id = p_booking_id;

  -- Calculate remaining amount (70% of total)
  v_remaining_amount := v_booking.total_amount - v_booking.deposit_amount;
  v_platform_fee := v_remaining_amount * 0.10;
  v_shop_net := v_remaining_amount - v_platform_fee;

  -- Lock and update wallet
  PERFORM 1 FROM wallets WHERE shop_id = v_shop_id FOR UPDATE;

  UPDATE wallets SET
    balance = balance + v_shop_net,
    total_earned = total_earned + v_remaining_amount,
    total_fees = total_fees + v_platform_fee,
    updated_at = NOW()
  WHERE shop_id = v_shop_id;

  -- Record transactions
  INSERT INTO wallet_transactions (shop_id, type, amount, balance_after, reference)
  SELECT v_shop_id, 'service_payment', v_shop_net, balance, p_booking_id::TEXT
  FROM wallets WHERE shop_id = v_shop_id;

  INSERT INTO wallet_transactions (shop_id, type, amount, balance_after, reference)
  SELECT v_shop_id, 'platform_fee', -v_platform_fee, balance, p_booking_id::TEXT
  FROM wallets WHERE shop_id = v_shop_id;

  RETURN jsonb_build_object('booking_id', p_booking_id, 'remaining_amount', v_remaining_amount, 'platform_fee', v_platform_fee, 'shop_net', v_shop_net);
END;
$$;
```

## 🔌 Edge Functions

### Paystack Subaccount Edge Function

**Location**: `supabase/functions/paystack-subaccount/index.ts`

| Action              | Purpose                                                            |
| ------------------- | ------------------------------------------------------------------ |
| `fetch-banks`       | Get banks by currency code from Paystack API                       |
| `create-subaccount` | Create subaccount and transfer recipient, save to payment_settings |
| `get-status`        | Check connection status for shop                                   |
| `disconnect`        | Remove Paystack connection from payment_settings                   |

### Stripe Connect Edge Function

**Location**: `supabase/functions/stripe-connect/index.ts`

| Action              | Purpose                                                  |
| ------------------- | -------------------------------------------------------- |
| `create-oauth-link` | Generate OAuth URL with state nonce for CSRF protection  |
| `handle-callback`   | Exchange code for access token, save to payment_settings |
| `get-status`        | Check connection status for shop                         |
| `disconnect`        | Deauthorize Stripe account, remove from payment_settings |

### Process Withdrawal Edge Function

**Location**: `supabase/functions/process-withdrawal/index.ts`

| Step | Purpose                                                     |
| ---- | ----------------------------------------------------------- |
| 1    | Fetch withdrawal request with payment_settings              |
| 2    | Update status to 'processing'                               |
| 3    | If Paystack: call transfer API with recipient code          |
| 4    | If Stripe: create transfer to connected account             |
| 5    | On success: update status to 'completed', store transfer ID |
| 6    | On failure: update status to 'failed', refund wallet        |
| 7    | Update wallet: subtract from pending_withdrawals            |

### Database Webhook Trigger

```sql
CREATE OR REPLACE FUNCTION trigger_process_withdrawal()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://[PROJECT_REF].supabase.co/functions/v1/process-withdrawal',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := jsonb_build_object('withdrawalId', NEW.id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_withdrawal_on_insert
  AFTER INSERT ON withdrawal_requests
  FOR EACH ROW WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION trigger_process_withdrawal();
```

## 📂 Repository Layer

### Payment Settings Repository Interface

**Location**: `lib/features/shops/payment/data/repositories/payment_settings_repository.dart`

| Method                       | Purpose                                               |
| ---------------------------- | ----------------------------------------------------- |
| `getSettings()`              | Fetch payment settings for a shop                     |
| `watchSettings()`            | Stream real-time payment settings changes             |
| `createPaystackSubaccount()` | Call Edge Function to create subaccount and recipient |
| `getStripeOAuthUrl()`        | Generate Stripe OAuth URL via Edge Function           |
| `handleStripeCallback()`     | Process OAuth callback with code and state            |
| `disconnectProvider()`       | Remove payment provider connection                    |
| `fetchBanks()`               | Get banks by currency code from Paystack              |

### Wallet Repository Interface

**Location**: `lib/features/shops/wallet/data/repositories/wallet_repository.dart`

| Method                  | Purpose                                      |
| ----------------------- | -------------------------------------------- |
| `getWallet()`           | Fetch wallet for a shop                      |
| `watchWallet()`         | Stream real-time wallet balance changes      |
| `getTransactions()`     | Paginated transaction history                |
| `getWithdrawals()`      | Paginated withdrawal requests                |
| `requestWithdrawal()`   | Create withdrawal request (calls atomic RPC) |
| `getAvailableBalance()` | Calculate balance - pending_withdrawals      |

## 🧠 State Management

### Payment Setup Providers

**Location**: `lib/features/shops/payment/providers/payment_setup_provider.dart`

| Provider                            | Type                  | Purpose                              |
| ----------------------------------- | --------------------- | ------------------------------------ |
| `paymentSettingsRepositoryProvider` | Provider              | Singleton repository instance        |
| `paymentSetupStatusProvider`        | StreamProvider        | Boolean: is payment connected        |
| `connectedPaymentProviderProvider`  | StreamProvider        | String: 'paystack' or 'stripe'       |
| `paymentSettingsControllerProvider` | StateNotifierProvider | Actions: connect, disconnect, verify |

### Wallet Controller

**Location**: `lib/features/shops/wallet/presentation/controllers/wallet_controller.dart`

| State Property        | Type                    | Purpose                          |
| --------------------- | ----------------------- | -------------------------------- |
| `wallet`              | WalletModel             | Current wallet balance and stats |
| `transactions`        | List<WalletTransaction> | Paginated transaction list       |
| `withdrawals`         | List<WithdrawalRequest> | Paginated withdrawal list        |
| `isLoading`           | bool                    | Loading state indicator          |
| `hasMoreTransactions` | bool                    | More transactions available      |
| `hasMoreWithdrawals`  | bool                    | More withdrawals available       |
| `error`               | String?                 | Error message if operation fails |

| Method                   | Purpose                                   |
| ------------------------ | ----------------------------------------- |
| `loadWallet()`           | Fetch current wallet data                 |
| `loadTransactions()`     | Fetch transaction history with pagination |
| `loadWithdrawals()`      | Fetch withdrawal history with pagination  |
| `requestWithdrawal()`    | Create withdrawal request with validation |
| `loadMoreTransactions()` | Append next page of transactions          |
| `loadMoreWithdrawals()`  | Append next page of withdrawals           |

### Wallet Providers

**Location**: `lib/features/shops/wallet/providers/wallet_providers.dart`

| Provider                         | Type                  | Purpose                         |
| -------------------------------- | --------------------- | ------------------------------- |
| `walletRepositoryProvider`       | Provider              | Singleton repository instance   |
| `walletControllerProviderFamily` | StateNotifierProvider | Wallet state per shop           |
| `walletBalanceProvider`          | FutureProvider        | Quick access to current balance |

## 🎨 UI Components (Paths Only)

### Payment Screens

| Screen                  | Path                                                                           | Purpose                                  |
| ----------------------- | ------------------------------------------------------------------------------ | ---------------------------------------- |
| `PaymentSettingsScreen` | `lib/features/shops/payment/presentation/screens/payment_settings_screen.dart` | Connect/disconnect Paystack/Stripe       |
| `WalletScreen`          | `lib/features/shops/wallet/presentation/screens/wallet_screen.dart`            | Balance, transactions, withdrawal button |

### Payment Widgets

| Widget                   | Path                                                                            | Purpose                                     |
| ------------------------ | ------------------------------------------------------------------------------- | ------------------------------------------- |
| `PaystackConnectionCard` | `lib/features/shops/payment/presentation/widgets/paystack_connection_card.dart` | Bank selection, account verification form   |
| `StripeConnectionCard`   | `lib/features/shops/payment/presentation/widgets/stripe_connection_card.dart`   | OAuth connect button with status            |
| `PayoutSettingsCard`     | `lib/features/shops/payment/presentation/widgets/payout_settings_card.dart`     | Auto-payout toggle, schedule, minimum       |
| `FeeInfoCard`            | `lib/features/shops/payment/presentation/widgets/fee_info_card.dart`            | Platform fee breakdown (2.9% + fixed)       |
| `RegionInfoCard`         | `lib/features/shops/payment/presentation/widgets/region_info_card.dart`         | Available providers by currency             |
| `WalletBalanceCard`      | `lib/features/shops/wallet/presentation/widgets/wallet_balance_card.dart`       | Available balance, pending withdrawals      |
| `TransactionListItem`    | `lib/features/shops/wallet/presentation/widgets/transaction_list_item.dart`     | Individual transaction row with icon        |
| `WithdrawalSheet`        | `lib/features/shops/wallet/presentation/widgets/withdrawal_sheet.dart`          | Amount input, fee calculation, confirmation |

## 🔄 Key Flows

### Paystack Connection Flow

```
Shop owner opens Payment Settings
        ↓
Selects Paystack → fetches banks by currency
        ↓
Selects bank → inputs account number
        ↓
Verification call to Paystack API
        ↓
On success → create-subaccount Edge Function called
        ↓
Subaccount and transfer recipient created
        ↓
payment_settings table updated with provider='paystack'
        ↓
UI shows "Connected" status
```

### Stripe Connect Flow

```
Shop owner clicks "Connect with Stripe"
        ↓
Edge Function generates OAuth URL with state nonce
        ↓
State stored in oauth_states table (expires in 10 min)
        ↓
WebView opens Stripe OAuth page
        ↓
Shop owner authorizes → redirects to callback URL
        ↓
Edge Function exchanges code for access token
        ↓
payment_settings table updated with provider='stripe'
        ↓
UI shows "Connected" status
```

### Withdrawal Request Flow

```
Shop owner opens Wallet screen
        ↓
Clicks "Withdraw" → WithdrawalSheet opens
        ↓
Enters amount (min GHS 50, max daily GHS 5000)
        ↓
System calculates 2% fee (min GHS 1)
        ↓
Confirmation → requestWithdrawal() called
        ↓
create_withdrawal_request() RPC called with idempotency key
        ↓
Validates available balance → locks wallet row
        ↓
Creates withdrawal_request record
        ↓
Database webhook triggers process-withdrawal Edge Function
        ↓
Immediate processing via Paystack/Stripe API
        ↓
On success: Wallet updated, pending_withdrawals reduced
        ↓
UI updates with "Completed" status
```

### Withdrawal Rules

| Rule                    | Value                            |
| ----------------------- | -------------------------------- |
| Minimum Withdrawal      | GHS 50                           |
| Maximum Per Transaction | GHS 5,000                        |
| Daily Limit             | GHS 5,000 (1 withdrawal per day) |
| Processing Fee          | 2% (minimum GHS 1)               |
| Processing Time         | Immediate (via Edge Function)    |

## 📦 Dependencies Added in Phase 4

```yaml
dependencies:
  flutter_stripe: ^10.0.0
  paystack_sdk: ^1.0.0
  webview_flutter: ^4.4.0
```

## 📁 Phase 4 Folder Structure

```
lib/features/shops/
├── payment/
│   ├── data/
│   │   ├── models/
│   │   │   └── payment_settings_model.dart
│   │   └── repositories/
│   │       └── payment_settings_repository.dart
│   ├── presentation/
│   │   ├── controllers/
│   │   │   └── payment_settings_controller.dart
│   │   ├── screens/
│   │   │   └── payment_settings_screen.dart
│   │   └── widgets/
│   │       ├── paystack_connection_card.dart
│   │       ├── stripe_connection_card.dart
│   │       ├── payout_settings_card.dart
│   │       ├── fee_info_card.dart
│   │       └── region_info_card.dart
│   └── providers/
│       └── payment_setup_provider.dart
│
└── wallet/
    ├── data/
    │   ├── models/
    │   │   ├── wallet_model.dart
    │   │   ├── wallet_transaction_model.dart
    │   │   └── withdrawal_request_model.dart
    │   ├── repositories/
    │   │   └── supabase_wallet_repository.dart
    │   └── exceptions/
    │       └── wallet_exceptions.dart
    ├── presentation/
    │   ├── controllers/
    │   │   └── wallet_controller.dart
    │   ├── screens/
    │   │   └── wallet_screen.dart
    │   └── widgets/
    │       ├── wallet_balance_card.dart
    │       ├── transaction_list_item.dart
    │       └── withdrawal_sheet.dart
    └── providers/
        └── wallet_providers.dart
```

## ⏭️ Next Phase

**Phase 5: Calendar & Schedule**, which implements unified calendar for clients and shop owners, daily schedule view, and appointment caching.