import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';
import '../../domain/entities/monitoring_report.dart';

// Constantes de diseño para el módulo de informes
const Color _primaryColor = Color(0xFFF5A623);
const Color _backgroundLight = Color(0xFFF8F5F0);
const Color _textPrimary = Color(0xFF2D2D2D);

class ReportsPage extends ConsumerWidget {
  final String hiveId;
  final String hiveNumber;

  const ReportsPage({
    super.key,
    required this.hiveId,
    required this.hiveNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider(hiveId));

    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Informes - Colmena $hiveNumber',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.reports.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reports.length,
                      itemBuilder: (context, index) {
                        final report = state.reports[index];
                        return _buildReportCard(context, report);
                      },
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay informes generados aún.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MonitoringReport report) {
    final dateStr = DateFormat('dd/MM/yyyy').format(report.timestamp);
    final timeStr = DateFormat('HH:mm').format(report.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.assignment_turned_in_rounded, color: _primaryColor),
        ),
        title: Text(
          'Monitoreo del $dateStr',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        subtitle: Text(
          'Hora: $timeStr - ${report.answers.length} respuestas',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Puntaje',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '${report.totalScore}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _primaryColor,
              ),
            ),
          ],
        ),
        onTap: () => _showReportDetail(context, report),
      ),
    );
  }

  void _showReportDetail(BuildContext context, MonitoringReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportDetailBottomSheet(report: report),
    );
  }
}

class _ReportDetailBottomSheet extends StatelessWidget {
  final MonitoringReport report;

  const _ReportDetailBottomSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(report.timestamp);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle del Informe',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: ${report.totalScore}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: report.answers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final ans = report.answers[index];
                // Intentamos obtener el texto de la pregunta de la relación apiaryQuestion
                final preguntaTexto = ans.hiveQuestion?.apiaryQuestion?.texto ?? 
                                     'Pregunta #${index + 1}';
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preguntaTexto,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: _primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ans.answer,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (ans.score != null && ans.score != 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${ans.score}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
