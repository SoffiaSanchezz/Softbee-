import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../controllers/insights_controller.dart';

class ApiaryInsightsPage extends ConsumerStatefulWidget {
  final String apiaryId;
  final String apiaryName;

  const ApiaryInsightsPage({
    super.key,
    required this.apiaryId,
    required this.apiaryName,
  });

  @override
  ConsumerState<ApiaryInsightsPage> createState() => _ApiaryInsightsPageState();
}

class _ApiaryInsightsPageState extends ConsumerState<ApiaryInsightsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      ref.read(insightsControllerProvider.notifier).refreshAll(widget.apiaryId)
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsControllerProvider);
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 1200;
    final bool isTablet = size.width > 700 && size.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              if (state.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.amber)))
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildAiHeroSection(state, isDesktop),
                      const SizedBox(height: 30),
                      _buildMetricsGrid(state.generalStats, size.width),
                      const SizedBox(height: 30),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildMainCharts(state)),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _buildInventoryStatus(state.inventoryLevels)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildMainCharts(state),
                            const SizedBox(height: 30),
                            _buildInventoryStatus(state.inventoryLevels),
                          ],
                        ),
                      const SizedBox(height: 50),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
        title: Text(
          widget.apiaryName,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
          onPressed: () => ref.read(insightsControllerProvider.notifier).refreshAll(widget.apiaryId),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildAiHeroSection(AdvancedInsightsState state, bool isDesktop) {
    final ai = state.aiAnalysis;
    final isLo = state.isAiLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D3436)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Análisis Estratégico Maya",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 22 : 18,
                  ),
                ),
              ),
              if (ai != null)
                _buildStatusBadge(ai['status']),
            ],
          ),
          const SizedBox(height: 20),
          if (isLo)
            const LinearProgressIndicator(backgroundColor: Colors.white10, color: Colors.amber)
          else if (ai != null)
            Text(
              ai['response'],
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: isDesktop ? 16 : 15,
                height: 1.6,
              ),
            )
          else
            Text(
              "Cargando análisis inteligente...",
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'saludable' ? Colors.green : (status == 'alerta' ? Colors.red : Colors.amber);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic>? stats, double width) {
    int crossAxisCount = 2;
    double aspectRatio = 1.3;

    if (width > 1000) {
      crossAxisCount = 4;
      aspectRatio = 1.5;
    } else if (width > 600) {
      crossAxisCount = 3;
      aspectRatio = 1.4;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        _buildMetricCard("Salud Promedio", "${stats?['avg_health_score'] ?? 0}%", Icons.favorite_rounded, Colors.redAccent, "+2.4%"),
        _buildMetricCard("Colmenas", "${stats?['total_beehives'] ?? 0}", Icons.hive_rounded, Colors.amber, "Estable"),
        _buildMetricCard("Tratamientos", "${stats?['active_treatments'] ?? 0}", Icons.healing_rounded, Colors.blueAccent, "-15%"),
        _buildMetricCard("Inventario", "${stats?['low_stock_items'] ?? 0}", Icons.inventory_2_rounded, Colors.orangeAccent, "Alerta"),
      ],
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Flexible(
                child: Text(
                  trend, 
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(val, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
              ),
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildMainCharts(AdvancedInsightsState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Evolución de Salud Global", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: LineChart(_getHealthChartData(state.healthTrends)),
          ),
        ],
      ),
    );
  }

  LineChartData _getHealthChartData(List<dynamic>? trends) {
    if (trends == null || trends.isEmpty) return LineChartData();
    
    // Simplificamos: tomamos los data_points de la primera colmena que los tenga
    final points = trends.first['data_points'] as List;
    final List<FlSpot> spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['score'] as num).toDouble());
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.amber,
          barWidth: 6,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.amber.withOpacity(0.3), Colors.amber.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStatus(List<dynamic>? items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Niveles de Suministros", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...?items?.map((item) => _buildInventoryBar(item)),
        ],
      ),
    );
  }

  Widget _buildInventoryBar(Map<String, dynamic> item) {
    final double percent = (item['current_quantity'] / (item['minimum_stock'] * 2)).clamp(0.0, 1.0);
    final color = item['status'] == 'ok' ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['item_name'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              Text("${item['current_quantity']} uds", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
