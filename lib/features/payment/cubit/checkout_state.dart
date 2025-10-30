import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/orders/data/models/order_model.dart';

enum CheckoutStatus { initial, selecting, processing, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.selectedMethod = 'razorpay',
    this.selectedUpiApp,
    this.errorMessage,
    this.infoMessage,
    this.lastOrder,
  });

  final CheckoutStatus status;
  final String selectedMethod;
  final String? selectedUpiApp;
  final String? errorMessage;
  final String? infoMessage;
  final OrderModel? lastOrder;

  bool get isProcessing => status == CheckoutStatus.processing;

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? selectedMethod,
    String? selectedUpiApp,
    String? errorMessage,
    String? infoMessage,
    OrderModel? lastOrder,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedUpiApp: selectedUpiApp ?? this.selectedUpiApp,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
      lastOrder: lastOrder ?? this.lastOrder,
    );
  }

  @override
  List<Object?> get props =>
      [status, selectedMethod, selectedUpiApp, errorMessage, infoMessage, lastOrder];
}
