import assert from "node:assert/strict";
import test from "node:test";

import { greeting } from "./index.js";

test("greeting", () => {
  assert.equal(greeting("Nix"), "Hello, Nix!");
});
