// lib/features/freelancer/data/repositories/tool_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tool.dart';

// lib/features/freelancer/data/repositories/tool_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tool.dart';

/// Repository for managing freelancer tools (equipment)
/// Similar to AmenityRepository for shops
class ToolRepository {
  final SupabaseClient _client;

  ToolRepository(this._client);

  /// Get all available tools from the database
  Future<List<Tool>> getAllTools() async {
    try {
      // Remove .limit(1) to get ALL tools
      final response = await _client
          .from('tools')
          .select('*')
          .order('display_order', ascending: true);

      print('✅ Tools loaded: ${(response as List).length} tools found');

      // Print first few tools for verification
      if ((response as List).isNotEmpty) {
        print('📊 Sample tool: ${(response as List).first['name']}');
        print(
          '📊 Total categories: ${(response as List).map((t) => t['category']).toSet().length}',
        );
      }

      return (response as List).map((json) => Tool.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading tools from database: $e');
      // Fallback to default tools if database fetch fails
      return _getDefaultTools();
    }
  }

  /// Get tools grouped by category
  Future<List<ToolCategory>> getToolsByCategory() async {
    final tools = await getAllTools();

    print('📊 Grouping ${tools.length} tools by category');

    // Group by category
    final Map<String, List<Tool>> grouped = {};
    for (final tool in tools) {
      final category = tool.category;
      grouped.putIfAbsent(category, () => []).add(tool);
    }

    // Convert to list of ToolCategory
    return grouped.entries.map((entry) {
        return ToolCategory(
          name: entry.key,
          tools:
              entry.value
                ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
        );
      }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get tools by specific category
  Future<List<Tool>> getToolsByCategoryName(String categoryName) async {
    final allTools = await getAllTools();
    return allTools.where((tool) => tool.category == categoryName).toList();
  }

  /// Get freelancer's selected tools
  Future<List<String>> getFreelancerTools(String freelancerId) async {
    try {
      final response = await _client
          .from('freelancer_tools')
          .select('tool_id')
          .eq('freelancer_id', freelancerId);

      return (response as List)
          .map((json) => json['tool_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting freelancer tools: $e');
      return [];
    }
  }

  /// Update freelancer's tools
  Future<void> updateFreelancerTools({
    required String freelancerId,
    required List<String> toolIds,
  }) async {
    try {
      // Delete existing assignments
      await _client
          .from('freelancer_tools')
          .delete()
          .eq('freelancer_id', freelancerId);

      // Insert new assignments
      if (toolIds.isNotEmpty) {
        final assignments =
            toolIds
                .map(
                  (toolId) => {
                    'freelancer_id': freelancerId,
                    'tool_id': toolId,
                  },
                )
                .toList();

        await _client.from('freelancer_tools').insert(assignments);
        print('✅ Updated freelancer tools: ${toolIds.length} tools');
      }
    } catch (e) {
      print('❌ Failed to update freelancer tools: $e');
      throw Exception('Failed to update freelancer tools: $e');
    }
  }

  /// Default tools in case database fetch fails
  List<Tool> _getDefaultTools() {
    print('⚠️ Using default tools (database fetch failed)');
    return const [
      Tool(
        id: 'scissors',
        name: 'Scissors/Shears',
        iconCodePoint: 0xe14c,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 1,
      ),
      Tool(
        id: 'clippers',
        name: 'Clippers/Trimmers',
        iconCodePoint: 0xe1e3,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 2,
      ),
      Tool(
        id: 'razor',
        name: 'Straight Razor',
        iconCodePoint: 0xe32a,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 3,
      ),
      Tool(
        id: 'blow_dryer',
        name: 'Blow Dryer',
        iconCodePoint: 0xe94b,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 4,
      ),
      Tool(
        id: 'curling_iron',
        name: 'Curling Iron',
        iconCodePoint: 0xe3a5,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 5,
      ),
      Tool(
        id: 'flat_iron',
        name: 'Flat Iron',
        iconCodePoint: 0xe3f9,
        iconFontFamily: 'MaterialIcons',
        category: 'Hair',
        displayOrder: 6,
      ),
      Tool(
        id: 'uv_lamp',
        name: 'UV/LED Lamp',
        iconCodePoint: 0xe0b0,
        iconFontFamily: 'MaterialIcons',
        category: 'Nails',
        displayOrder: 20,
      ),
      Tool(
        id: 'nail_drill',
        name: 'Electric Nail File',
        iconCodePoint: 0xe869,
        iconFontFamily: 'MaterialIcons',
        category: 'Nails',
        displayOrder: 21,
      ),
      Tool(
        id: 'massage_table',
        name: 'Massage Table',
        iconCodePoint: 0xe90b,
        iconFontFamily: 'MaterialIcons',
        category: 'Massage',
        displayOrder: 40,
      ),
      Tool(
        id: 'hot_stones',
        name: 'Hot Stone Set',
        iconCodePoint: 0xe9a9,
        iconFontFamily: 'MaterialIcons',
        category: 'Massage',
        displayOrder: 42,
      ),
      Tool(
        id: 'brush_set',
        name: 'Professional Brush Set',
        iconCodePoint: 0xeae7,
        iconFontFamily: 'MaterialIcons',
        category: 'Makeup',
        displayOrder: 60,
      ),
      Tool(
        id: 'airbrush',
        name: 'Airbrush System',
        iconCodePoint: 0xe94b,
        iconFontFamily: 'MaterialIcons',
        category: 'Makeup',
        displayOrder: 62,
      ),
    ];
  }
}

// =====================================================
// Providers
// =====================================================

final toolRepositoryProvider = Provider<ToolRepository>((ref) {
  final client = Supabase.instance.client;
  return ToolRepository(client);
});

final allToolsProvider = FutureProvider<List<Tool>>((ref) {
  final repository = ref.watch(toolRepositoryProvider);
  return repository.getAllTools();
});

final toolsByCategoryProvider = FutureProvider<List<ToolCategory>>((ref) {
  final repository = ref.watch(toolRepositoryProvider);
  return repository.getToolsByCategory();
});
