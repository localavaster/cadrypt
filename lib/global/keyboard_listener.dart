class Keyboard {
  final List<int> keysPressed = [];

  void onKeyDown(int key) {
    if (!keysPressed.contains(key)) {
      keysPressed.add(key);
    }
  }

  void onKeyUp(int key) {
    if (keysPressed.contains(key)) {
      keysPressed.remove(key);
    }
  }
}
