// Enum to represent fault types
enum FaultType { lineToLine, lineToGround, none }

// Enum to represent fault categories
enum FaultCategory { category1, category2, category3, none }

// Class representing a fault
class Fault {
  final FaultType type;
  final FaultCategory category;
  final DateTime timestamp;

  Fault({required this.type, required this.category, required this.timestamp});

  // Method to check if fault type and category are none
  bool get isNone => type == FaultType.none && category == FaultCategory.none;

  // Method to get the name of the fault type
  String getTypeName() {
    return type == FaultType.lineToLine ? 'Line to Line' : 'Line to Ground';
  }

  // Method to get the name of the fault category
  String getCategoryName() {
    if (FaultType.lineToLine == type) {
    switch (category) {
      case FaultCategory.category1:
        return 'AB Fault';
      case FaultCategory.category2:
        return 'AC Fault';
      case FaultCategory.category3:
        return 'BC Fault';
      case FaultCategory.none:
        return 'None';
    }  
    }
    else if(type == FaultType.lineToGround){
        switch (category) {
      case FaultCategory.category1:
        return 'AB Fault';
      case FaultCategory.category2:
        return 'AG Fault';
      case FaultCategory.category3:
        return 'BG Fault';
      case FaultCategory.none:
        return 'None';
    }  }

  else {
    return "None";
  }
  }

}
