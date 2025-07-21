import 'package:flutter/material.dart';

// Custom Theme Data (matching your app theme)
class AppTheme {
  static const Color sage = Color(0xFF606C38);
  static const Color darkGreen = Color(0xFF283618);
  static const Color cream = Color(0xFFFEFAE0);
  static const Color golden = Color(0xFFDDA15E);
  static const Color bronze = Color(0xFFBC6C25);
}

// Filter Model for managing filter state
class FilterModel {
  // Text Search Filters
  String searchQuery = '';
  String txnRefNo = '';
  String txnMachine = '';
  String txnMID = '';
  String txnSource = '';

  // Dropdown Filters
  String selectedTxnType = 'All';
  String selectedStatus = 'All';
  String selectedPaymentMethod = 'All';

  // Date Range Filters
  DateTime? startDate;
  DateTime? endDate;

  // Amount Range Filters
  double? minAmount;
  double? maxAmount;

  // Boolean Filters
  bool showOnlyMatches = false;
  bool showOnlyMismatches = false;
  bool showOnlyPayments = false;
  bool showOnlyRefunds = false;

  // Gateway Specific Filters
  bool hasPaytmTransactions = false;
  bool hasPhonepeTransactions = false;
  bool hasCardTransactions = false;
  bool hasCashTransactions = false;

  // Clear all filters
  void clearAll() {
    searchQuery = '';
    txnRefNo = '';
    txnMachine = '';
    txnMID = '';
    txnSource = '';
    selectedTxnType = 'All';
    selectedStatus = 'All';
    selectedPaymentMethod = 'All';
    startDate = null;
    endDate = null;
    minAmount = null;
    maxAmount = null;
    showOnlyMatches = false;
    showOnlyMismatches = false;
    showOnlyPayments = false;
    showOnlyRefunds = false;
    hasPaytmTransactions = false;
    hasPhonepeTransactions = false;
    hasCardTransactions = false;
    hasCashTransactions = false;
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        txnRefNo.isNotEmpty ||
        txnMachine.isNotEmpty ||
        txnMID.isNotEmpty ||
        txnSource.isNotEmpty ||
        selectedTxnType != 'All' ||
        selectedStatus != 'All' ||
        selectedPaymentMethod != 'All' ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        showOnlyMatches ||
        showOnlyMismatches ||
        showOnlyPayments ||
        showOnlyRefunds ||
        hasPaytmTransactions ||
        hasPhonepeTransactions ||
        hasCardTransactions ||
        hasCashTransactions;
  }
}

// Filter Results Model
class FilterResults {
  final List<dynamic> filteredData;
  final int totalRecords;
  final double totalCloudAmount;
  final double totalGatewayAmount;
  final int matchedRecords;
  final int mismatchedRecords;
  final double matchPercentage;
  final Map<String, int> statusBreakdown;
  final Map<String, double> amountBreakdown;

  FilterResults({
    required this.filteredData,
    required this.totalRecords,
    required this.totalCloudAmount,
    required this.totalGatewayAmount,
    required this.matchedRecords,
    required this.mismatchedRecords,
    required this.matchPercentage,
    required this.statusBreakdown,
    required this.amountBreakdown,
  });
}

// Main Filter Component
class FilterComponent extends StatefulWidget {
  final List<dynamic> originalData;
  final Function(FilterResults) onFilterChanged;
  final FilterModel? initialFilter;

  const FilterComponent({
    super.key,
    required this.originalData,
    required this.onFilterChanged,
    this.initialFilter,
  });

  @override
  State<FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent>
    with TickerProviderStateMixin {
  late FilterModel _filterModel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  // Dropdown options
  final List<String> _txnTypes = [
    'All',
    'Payment',
    'Refund',
    'Transfer',
    'Adjustment'
  ];
  final List<String> _statusOptions = [
    'All',
    'Perfect Match',
    'Mismatch',
    'Pending Review'
  ];
  final List<String> _paymentMethods = [
    'All',
    'Paytm',
    'PhonePe',
    'Card',
    'Cash',
    'VMSMoney',
    'Sodexo',
    'HDFC'
  ];

  @override
  void initState() {
    super.initState();
    _filterModel = widget.initialFilter ?? FilterModel();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Apply initial filter after the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Parse double values safely
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Apply all filters to data
  void _applyFilters() {
    List<dynamic> filtered = List.from(widget.originalData);

    // Text search filters
    if (_filterModel.searchQuery.isNotEmpty) {
      final query = _filterModel.searchQuery.toLowerCase();
      filtered = filtered.where((record) {
        return record['Txn_RefNo']?.toString().toLowerCase().contains(query) ==
                true ||
            record['Txn_Machine']?.toString().toLowerCase().contains(query) ==
                true ||
            record['Txn_MID']?.toString().toLowerCase().contains(query) ==
                true ||
            record['Txn_Source']?.toString().toLowerCase().contains(query) ==
                true;
      }).toList();
    }

    // Specific field filters
    if (_filterModel.txnRefNo.isNotEmpty) {
      filtered = filtered.where((record) {
        return record['Txn_RefNo']
                ?.toString()
                .toLowerCase()
                .contains(_filterModel.txnRefNo.toLowerCase()) ==
            true;
      }).toList();
    }

    if (_filterModel.txnMachine.isNotEmpty) {
      filtered = filtered.where((record) {
        return record['Txn_Machine']
                ?.toString()
                .toLowerCase()
                .contains(_filterModel.txnMachine.toLowerCase()) ==
            true;
      }).toList();
    }

    if (_filterModel.txnMID.isNotEmpty) {
      filtered = filtered.where((record) {
        return record['Txn_MID']
                ?.toString()
                .toLowerCase()
                .contains(_filterModel.txnMID.toLowerCase()) ==
            true;
      }).toList();
    }

    if (_filterModel.txnSource.isNotEmpty) {
      filtered = filtered.where((record) {
        return record['Txn_Source']
                ?.toString()
                .toLowerCase()
                .contains(_filterModel.txnSource.toLowerCase()) ==
            true;
      }).toList();
    }

    // Dropdown filters
    if (_filterModel.selectedTxnType != 'All') {
      filtered = filtered.where((record) {
        return record['Txn_Type']?.toString() == _filterModel.selectedTxnType;
      }).toList();
    }

    if (_filterModel.selectedPaymentMethod != 'All') {
      filtered = filtered.where((record) {
        final method = _filterModel.selectedPaymentMethod;
        return _parseDouble(record['${method}_Payment']) > 0 ||
            _parseDouble(record['${method}_Refund']) > 0;
      }).toList();
    }

    // Date range filters
    if (_filterModel.startDate != null || _filterModel.endDate != null) {
      filtered = filtered.where((record) {
        final dateStr = record['Txn_Date']?.toString();
        if (dateStr == null) return false;

        try {
          final recordDate = DateTime.parse(dateStr.split('T')[0]);

          if (_filterModel.startDate != null &&
              recordDate.isBefore(_filterModel.startDate!)) {
            return false;
          }
          if (_filterModel.endDate != null &&
              recordDate.isAfter(_filterModel.endDate!)) {
            return false;
          }
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Amount range filters
    if (_filterModel.minAmount != null || _filterModel.maxAmount != null) {
      filtered = filtered.where((record) {
        final cloudTotal = _parseDouble(record['Cloud_Payment']) +
            _parseDouble(record['Cloud_Refund']) +
            _parseDouble(record['Cloud_MRefund']);

        if (_filterModel.minAmount != null &&
            cloudTotal < _filterModel.minAmount!) {
          return false;
        }
        if (_filterModel.maxAmount != null &&
            cloudTotal > _filterModel.maxAmount!) {
          return false;
        }
        return true;
      }).toList();
    }

    // Boolean filters
    if (_filterModel.showOnlyMatches || _filterModel.showOnlyMismatches) {
      filtered = filtered.where((record) {
        final isMatch = _isMatchingRecord(record);
        if (_filterModel.showOnlyMatches && !isMatch) return false;
        if (_filterModel.showOnlyMismatches && isMatch) return false;
        return true;
      }).toList();
    }

    if (_filterModel.showOnlyPayments) {
      filtered = filtered.where((record) {
        final totalPayments = _parseDouble(record['Cloud_Payment']) +
            _parseDouble(record['Paytm_Payment']) +
            _parseDouble(record['Phonepe_Payment']) +
            _parseDouble(record['VMSMoney_Payment']) +
            _parseDouble(record['Card_Payment']) +
            _parseDouble(record['Sodexo_Payment']) +
            _parseDouble(record['HDFC_Payment']) +
            _parseDouble(record['CASH_Payment']);
        return totalPayments > 0;
      }).toList();
    }

    if (_filterModel.showOnlyRefunds) {
      filtered = filtered.where((record) {
        final totalRefunds = _parseDouble(record['Cloud_Refund']) +
            _parseDouble(record['Cloud_MRefund']) +
            _parseDouble(record['Paytm_Refund']) +
            _parseDouble(record['Phonepe_Refund']) +
            _parseDouble(record['VMSMoney_Refund']) +
            _parseDouble(record['Card_Refund']) +
            _parseDouble(record['Sodexo_Refund']) +
            _parseDouble(record['HDFC_Refund']);
        return totalRefunds > 0;
      }).toList();
    }

    // Gateway specific filters
    if (_filterModel.hasPaytmTransactions) {
      filtered = filtered.where((record) {
        return _parseDouble(record['Paytm_Payment']) > 0 ||
            _parseDouble(record['Paytm_Refund']) > 0;
      }).toList();
    }

    if (_filterModel.hasPhonepeTransactions) {
      filtered = filtered.where((record) {
        return _parseDouble(record['Phonepe_Payment']) > 0 ||
            _parseDouble(record['Phonepe_Refund']) > 0;
      }).toList();
    }

    if (_filterModel.hasCardTransactions) {
      filtered = filtered.where((record) {
        return _parseDouble(record['Card_Payment']) > 0 ||
            _parseDouble(record['Card_Refund']) > 0;
      }).toList();
    }

    if (_filterModel.hasCashTransactions) {
      filtered = filtered.where((record) {
        return _parseDouble(record['CASH_Payment']) > 0;
      }).toList();
    }

    // Calculate results and notify parent
    final results = _calculateResults(filtered);
    widget.onFilterChanged(results);
  }

  // Calculate comprehensive filter results
  FilterResults _calculateResults(List<dynamic> filteredData) {
    double totalCloudAmount = 0;
    double totalGatewayAmount = 0;
    int matchedRecords = 0;
    int mismatchedRecords = 0;
    Map<String, int> statusBreakdown = {};
    Map<String, double> amountBreakdown = {};

    for (var record in filteredData) {
      // Calculate cloud total
      final cloudTotal = _parseDouble(record['Cloud_Payment']) +
          _parseDouble(record['Cloud_Refund']) +
          _parseDouble(record['Cloud_MRefund']);
      totalCloudAmount += cloudTotal;

      // Calculate gateway total
      final gatewayTotal = _parseDouble(record['Paytm_Payment']) +
          _parseDouble(record['Phonepe_Payment']) +
          _parseDouble(record['VMSMoney_Payment']) +
          _parseDouble(record['Card_Payment']) +
          _parseDouble(record['Sodexo_Payment']) +
          _parseDouble(record['HDFC_Payment']) +
          _parseDouble(record['CASH_Payment']) -
          _parseDouble(record['Paytm_Refund']) -
          _parseDouble(record['Phonepe_Refund']) -
          _parseDouble(record['VMSMoney_Refund']) -
          _parseDouble(record['Card_Refund']) -
          _parseDouble(record['Sodexo_Refund']) -
          _parseDouble(record['HDFC_Refund']);
      totalGatewayAmount += gatewayTotal;

      // Count matches/mismatches
      if (_isMatchingRecord(record)) {
        matchedRecords++;
      } else {
        mismatchedRecords++;
      }

      // Status breakdown
      final txnType = record['Txn_Type']?.toString() ?? 'Unknown';
      statusBreakdown[txnType] = (statusBreakdown[txnType] ?? 0) + 1;

      // Amount breakdown by gateway
      for (String gateway in [
        'Paytm',
        'Phonepe',
        'VMSMoney',
        'Card',
        'Sodexo',
        'HDFC',
        'CASH'
      ]) {
        final amount = _parseDouble(record['${gateway}_Payment']) -
            _parseDouble(record['${gateway}_Refund']);
        if (amount != 0) {
          amountBreakdown[gateway] = (amountBreakdown[gateway] ?? 0) + amount;
        }
      }
    }

    final matchPercentage = filteredData.isNotEmpty
        ? (matchedRecords / filteredData.length * 100)
        : 0.0;

    return FilterResults(
      filteredData: filteredData,
      totalRecords: filteredData.length,
      totalCloudAmount: totalCloudAmount,
      totalGatewayAmount: totalGatewayAmount,
      matchedRecords: matchedRecords,
      mismatchedRecords: mismatchedRecords,
      matchPercentage: matchPercentage,
      statusBreakdown: statusBreakdown,
      amountBreakdown: amountBreakdown,
    );
  }

  // Check if record is matching
  bool _isMatchingRecord(Map<String, dynamic> record) {
    final cloudTotal = _parseDouble(record['Cloud_Payment']) +
        _parseDouble(record['Cloud_Refund']) +
        _parseDouble(record['Cloud_MRefund']);
    final gatewayTotal = _parseDouble(record['Paytm_Payment']) +
        _parseDouble(record['Phonepe_Payment']) +
        _parseDouble(record['VMSMoney_Payment']) +
        _parseDouble(record['Card_Payment']) +
        _parseDouble(record['Sodexo_Payment']) +
        _parseDouble(record['HDFC_Payment']) +
        _parseDouble(record['CASH_Payment']) -
        _parseDouble(record['Paytm_Refund']) -
        _parseDouble(record['Phonepe_Refund']) -
        _parseDouble(record['VMSMoney_Refund']) -
        _parseDouble(record['Card_Refund']) -
        _parseDouble(record['Sodexo_Refund']) -
        _parseDouble(record['HDFC_Refund']);

    return (cloudTotal - gatewayTotal).abs() < 0.01;
  }

  // Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.cream.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Header
          _buildFilterHeader(),

          // Expandable Filter Content
          if (_isExpanded)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildFilterContent(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.sage.withOpacity(0.1),
            AppTheme.sage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.sage, AppTheme.darkGreen],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (_filterModel.hasActiveFilters)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bronze,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                },
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: AppTheme.sage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Search Bar (always visible)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Quick search across all fields...',
                hintStyle: TextStyle(color: AppTheme.sage),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.sage),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  _filterModel.searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Field Filters
          _buildSectionTitle('Text Filters'),
          const SizedBox(height: 12),
          _buildTextFilters(),

          const SizedBox(height: 24),

          // Dropdown Filters
          _buildSectionTitle('Category Filters'),
          const SizedBox(height: 12),
          _buildDropdownFilters(),

          const SizedBox(height: 24),

          // Date Range Filters
          _buildSectionTitle('Date Range'),
          const SizedBox(height: 12),
          _buildDateFilters(),

          const SizedBox(height: 24),

          // Amount Range Filters
          _buildSectionTitle('Amount Range'),
          const SizedBox(height: 12),
          _buildAmountFilters(),

          const SizedBox(height: 24),

          // Boolean Filters
          _buildSectionTitle('Quick Filters'),
          const SizedBox(height: 12),
          _buildBooleanFilters(),

          const SizedBox(height: 24),

          // Gateway Filters
          _buildSectionTitle('Payment Gateway Filters'),
          const SizedBox(height: 12),
          _buildGatewayFilters(),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.darkGreen,
      ),
    );
  }

  Widget _buildTextFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildTextField('Transaction RefNo', _filterModel.txnRefNo, (value) {
          setState(() {
            _filterModel.txnRefNo = value;
          });
          _applyFilters();
        }),
        _buildTextField('Machine', _filterModel.txnMachine, (value) {
          setState(() {
            _filterModel.txnMachine = value;
          });
          _applyFilters();
        }),
        _buildTextField('MID', _filterModel.txnMID, (value) {
          setState(() {
            _filterModel.txnMID = value;
          });
          _applyFilters();
        }),
        _buildTextField('Source', _filterModel.txnSource, (value) {
          setState(() {
            _filterModel.txnSource = value;
          });
          _applyFilters();
        }),
      ],
    );
  }

  Widget _buildTextField(
      String label, String value, Function(String) onChanged) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppTheme.sage),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildDropdown(
            'Transaction Type', _filterModel.selectedTxnType, _txnTypes,
            (value) {
          setState(() {
            _filterModel.selectedTxnType = value!;
          });
          _applyFilters();
        }),
        _buildDropdown('Status', _filterModel.selectedStatus, _statusOptions,
            (value) {
          setState(() {
            _filterModel.selectedStatus = value!;
          });
          _applyFilters();
        }),
        _buildDropdown('Payment Method', _filterModel.selectedPaymentMethod,
            _paymentMethods, (value) {
          setState(() {
            _filterModel.selectedPaymentMethod = value!;
          });
          _applyFilters();
        }),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      Function(String?) onChanged) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppTheme.sage),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
          dropdownColor: Colors.white,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: AppTheme.darkGreen),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField('Start Date', _filterModel.startDate, (date) {
            setState(() {
              _filterModel.startDate = date;
            });
            _applyFilters();
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField('End Date', _filterModel.endDate, (date) {
            setState(() {
              _filterModel.endDate = date;
            });
            _applyFilters();
          }),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? value, Function(DateTime?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            onChanged(date);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.sage, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value != null
                      ? '${value.day}/${value.month}/${value.year}'
                      : label,
                  style: TextStyle(
                    color: value != null ? AppTheme.darkGreen : AppTheme.sage,
                    fontSize: 14,
                  ),
                ),
              ),
              if (value != null)
                InkWell(
                  onTap: () => onChanged(null),
                  child: const Icon(Icons.clear_rounded,
                      color: AppTheme.sage, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountFilters() {
    return Row(
      children: [
        Expanded(
          child:
              _buildAmountField('Min Amount', _filterModel.minAmount, (value) {
            setState(() {
              _filterModel.minAmount = value;
            });
            _applyFilters();
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _buildAmountField('Max Amount', _filterModel.maxAmount, (value) {
            setState(() {
              _filterModel.maxAmount = value;
            });
            _applyFilters();
          }),
        ),
      ],
    );
  }

  Widget _buildAmountField(
      String label, double? value, Function(double?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.sage),
          prefixText: '₹',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final amount = double.tryParse(text);
          onChanged(amount);
        },
      ),
    );
  }

  Widget _buildBooleanFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildCheckboxFilter('Show Only Matches', _filterModel.showOnlyMatches,
            (value) {
          setState(() {
            _filterModel.showOnlyMatches = value;
            if (value) _filterModel.showOnlyMismatches = false;
          });
          _applyFilters();
        }),
        _buildCheckboxFilter(
            'Show Only Mismatches', _filterModel.showOnlyMismatches, (value) {
          setState(() {
            _filterModel.showOnlyMismatches = value;
            if (value) _filterModel.showOnlyMatches = false;
          });
          _applyFilters();
        }),
        _buildCheckboxFilter('Payments Only', _filterModel.showOnlyPayments,
            (value) {
          setState(() {
            _filterModel.showOnlyPayments = value;
            if (value) _filterModel.showOnlyRefunds = false;
          });
          _applyFilters();
        }),
        _buildCheckboxFilter('Refunds Only', _filterModel.showOnlyRefunds,
            (value) {
          setState(() {
            _filterModel.showOnlyRefunds = value;
            if (value) _filterModel.showOnlyPayments = false;
          });
          _applyFilters();
        }),
      ],
    );
  }

  Widget _buildCheckboxFilter(
      String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? AppTheme.sage.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? AppTheme.sage.withOpacity(0.3)
              : AppTheme.sage.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: AppTheme.sage,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: value ? AppTheme.darkGreen : AppTheme.sage,
              fontWeight: value ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildGatewayFilter('Has Paytm', _filterModel.hasPaytmTransactions,
            (value) {
          setState(() {
            _filterModel.hasPaytmTransactions = value;
          });
          _applyFilters();
        }),
        _buildGatewayFilter('Has PhonePe', _filterModel.hasPhonepeTransactions,
            (value) {
          setState(() {
            _filterModel.hasPhonepeTransactions = value;
          });
          _applyFilters();
        }),
        _buildGatewayFilter('Has Card', _filterModel.hasCardTransactions,
            (value) {
          setState(() {
            _filterModel.hasCardTransactions = value;
          });
          _applyFilters();
        }),
        _buildGatewayFilter('Has Cash', _filterModel.hasCashTransactions,
            (value) {
          setState(() {
            _filterModel.hasCashTransactions = value;
          });
          _applyFilters();
        }),
      ],
    );
  }

  Widget _buildGatewayFilter(
      String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: value
            ? LinearGradient(
                colors: [
                  AppTheme.golden.withOpacity(0.2),
                  AppTheme.golden.withOpacity(0.1),
                ],
              )
            : null,
        color: value ? null : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? AppTheme.golden.withOpacity(0.4)
              : AppTheme.sage.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value
                ? Icons.account_balance_wallet
                : Icons.account_balance_wallet_outlined,
            color: value ? AppTheme.golden : AppTheme.sage,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: value ? AppTheme.darkGreen : AppTheme.sage,
              fontWeight: value ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.golden,
            activeTrackColor: AppTheme.golden.withOpacity(0.3),
            inactiveThumbColor: AppTheme.sage.withOpacity(0.5),
            inactiveTrackColor: AppTheme.sage.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _filterModel.clearAll();
              });
              _applyFilters();
            },
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('Clear All Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _filterModel.hasActiveFilters ? _applyFilters : null,
            icon: const Icon(Icons.filter_alt_rounded),
            label: const Text('Apply Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sage,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Filter Results Display Component
class FilterResultsDisplay extends StatelessWidget {
  final FilterResults results;

  const FilterResultsDisplay({
    super.key,
    required this.results,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.bronze.withOpacity(0.1),
            AppTheme.golden.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bronze.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.bronze, AppTheme.golden],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filter Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Records',
                    results.totalRecords.toString(),
                    Icons.receipt_long_rounded,
                    AppTheme.sage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Cloud Amount',
                    _formatCurrency(results.totalCloudAmount),
                    Icons.cloud_rounded,
                    AppTheme.golden,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Gateway Amount',
                    _formatCurrency(results.totalGatewayAmount),
                    Icons.payment_rounded,
                    AppTheme.bronze,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Match Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Matches',
                    results.matchedRecords.toString(),
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Mismatches',
                    results.mismatchedRecords.toString(),
                    Icons.error_rounded,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Match Rate',
                    '${results.matchPercentage.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded,
                    AppTheme.darkGreen,
                  ),
                ),
              ],
            ),

            // Amount Difference Indicator
            if (results.totalCloudAmount != results.totalGatewayAmount) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Amount Difference: ${_formatCurrency((results.totalCloudAmount - results.totalGatewayAmount).abs())}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
