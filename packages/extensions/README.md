# Extensions

This packages exposes extensions system of Yukino. This can also be used to test your plugins.

## Installation

```yaml
dependencies:
    ...
    extensions:
        git:
            url: git://github.com/yukino-app/yukino.git
            path: packages/extensions
```

## Usage

```dart
import 'package:extensions/extensions.dart'; // Exposes all the models
import 'package:extensions/test.dart'; // Exposes test utilities
```