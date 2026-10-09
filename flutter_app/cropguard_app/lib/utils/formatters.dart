import 'package:intl/intl.dart';

class NumberFormatter {
  static String tons(double tons) {
    if (tons >= 1000000) {
      return '${(tons / 1000000).toStringAsFixed(1)}M tons';
    }
    if (tons >= 1000) {
      return '${(tons / 1000).toStringAsFixed(1)}K tons';
    }
    return '${tons.toStringAsFixed(0)} tons';
  }

  static String tonsFull(double tons) {
    if (tons >= 1000000) {
      return '${(tons / 1000000).toStringAsFixed(2)} million tons';
    }
    if (tons >= 1000) {
      return '${(tons / 1000).toStringAsFixed(1)} thousand tons';
    }
    return '${tons.toStringAsFixed(0)} tons';
  }

  static String percent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String capacity(double used, double total) {
    final pct = total > 0 ? (used / total) * 100 : 0.0;
    return '${(total - used).toStringAsFixed(0)}/${total.toStringAsFixed(0)} tons (${(100 - pct).toStringAsFixed(0)}% free)';
  }
}

class DateFormatter {
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Just now';
        }
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
