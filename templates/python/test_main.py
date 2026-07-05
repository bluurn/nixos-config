import unittest

from main import greeting


class GreetingTest(unittest.TestCase):
    def test_greeting(self) -> None:
        self.assertEqual(greeting("Nix"), "Hello, Nix!")


if __name__ == "__main__":
    unittest.main()
