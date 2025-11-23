import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveDataTable extends StatelessWidget {
  final Widget dataTable;

  const ResponsiveDataTable({
    super.key,
    required this.dataTable,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: dataTable,
        ),
      );
    }
    
    return dataTable;
  }
}

