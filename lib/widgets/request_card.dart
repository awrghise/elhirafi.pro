import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;

  const RequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.profession, // <-- تم التصحيح
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.city}: ${request.city}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Divider(height: 20),
            if (request.details != null && request.details!.isNotEmpty)
              Text(
                request.details!, // <-- تم التصحيح
                style: const TextStyle(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd – hh:mm a').format(request.createdAt), // <-- تم التصحيح
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to request details screen
                  },
                  child: const Text(AppStrings.viewDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        statusText = AppStrings.pendingRequests;
        break;
      case 'accepted':
        chipColor = Colors.green;
        statusText = AppStrings.acceptedRequests;
        break;
      case 'declined':
        chipColor = Colors.red;
        statusText = AppStrings.declinedRequests;
        break;
      default:
        chipColor = Colors.grey;
        statusText = AppStrings.unknown;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}
