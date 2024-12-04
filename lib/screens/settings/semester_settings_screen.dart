import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/semester_service.dart';

class SemesterSettingsScreen extends StatelessWidget {
  const SemesterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学期设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('开学时间'),
            subtitle: Text(
              Provider.of<SemesterService>(context).startDate != null
                  ? DateFormat('yyyy-MM-dd')
                      .format(Provider.of<SemesterService>(context).startDate!)
                  : '未设置',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    Provider.of<SemesterService>(context, listen: false)
                            .startDate ??
                        DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null && context.mounted) {
                await Provider.of<SemesterService>(context, listen: false)
                    .setStartDate(date);
              }
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '当前第${Provider.of<SemesterService>(context).currentWeek}周',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '提示：设置开学时间后，系统会自动计算当前教学周。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
