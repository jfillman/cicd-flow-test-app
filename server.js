const express = require('express');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'hello from cicd-flow-test-app (full chain test v2 - double test stage)!!!',
    version: process.env.APP_VERSION || 'dev',
  });
});

// Used by k8s/dev-deployment.yaml's readiness/liveness probes, and by
// integration-test.sh during the platform's test stage.
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`cicd-flow-test-app listening on :${port}`);
  });
}

module.exports = app;
