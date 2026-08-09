const { test, before, after } = require('node:test');
const assert = require('node:assert');
const app = require('../server');

let server;
let baseUrl;

before(() => {
  server = app.listen(0); // ephemeral port
  baseUrl = `http://localhost:${server.address().port}`;
});

after(() => {
  server.close();
});

test('GET / returns 200 with a message', async () => {
  const res = await fetch(`${baseUrl}/`);
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.ok(body.message);
});

test('GET /healthz returns 200 with status ok', async () => {
  const res = await fetch(`${baseUrl}/healthz`);
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.strictEqual(body.status, 'ok');
});
