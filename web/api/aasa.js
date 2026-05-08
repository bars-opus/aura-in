export default function handler(req, res) {
  res.setHeader('Content-Type', 'application/json');
  res.json({
    applinks: {
      apps: [],
      details: [
        {
          appID: 'A8RJ357U9Y.com.bars-Opus.florence',
          paths: ['/auth/callback'],
        },
      ],
    },
  });
}
