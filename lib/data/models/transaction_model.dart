/// Transaction Models - Smart Digital Tourism
/// Based on Database Design Document - Tables transactions & transaction_items

/// Transaction status enum matching database trx_status_enum
enum TransactionStatus {
  pending,
  paid,
  expired,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu Pembayaran';
      case TransactionStatus.paid:
        return 'Terbayar';
      case TransactionStatus.expired:
        return 'Kedaluwarsa';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
      case TransactionStatus.completed:
        return 'Selesai';
    }
  }

  bool get isActive =>
      this == TransactionStatus.paid || this == TransactionStatus.completed;

  static TransactionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'paid':
        return TransactionStatus.paid;
      case 'expired':
        return TransactionStatus.expired;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'completed':
        return TransactionStatus.completed;
      default:
        return TransactionStatus.pending;
    }
  }
}

/// Item type enum matching database item_type_enum
enum ItemType {
  ticket,
  homestay,
  packet;

  String get displayName {
    switch (this) {
      case ItemType.ticket:
        return 'Tiket Wisata';
      case ItemType.homestay:
        return 'Homestay';
      case ItemType.packet:
        return 'Paket';
    }
  }

  static ItemType fromString(String value) {
    switch (value) {
      case 'ticket':
        return ItemType.ticket;
      case 'homestay':
        return ItemType.homestay;
      case 'packet':
        return ItemType.packet;
      default:
        return ItemType.ticket;
    }
  }
}

/// Transaction model
class TransactionModel {
  final String id;
  final String userId;
  final String invoiceNumber;
  final double totalAmount;
  final TransactionStatus status;
  final String? paymentMethod;
  final String? paymentUrl;
  final DateTime? paidAt;
  final DateTime createdAt;

  // Additional fields
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentUrl,
    this.paidAt,
    required this.createdAt,
    this.items = const [],
  });

  String get totalAmountString {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: TransactionStatus.fromString(json['status'] as String),
      paymentMethod: json['payment_method'] as String?,
      paymentUrl: json['payment_url'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => TransactionItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'status': status.name,
      'payment_method': paymentMethod,
      'payment_url': paymentUrl,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'TransactionModel(id: $id, invoice: $invoiceNumber)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Transaction item model
class TransactionItemModel {
  final String id;
  final String transactionId;
  final ItemType itemType;
  final String referenceId;
  final int quantity;
  final double priceAtPurchase;
  final DateTime visitDate;
  final String? ticketCode;
  final bool isRedeemed;
  final DateTime? redeemedAt;

  // Additional fields for display
  final String? itemName;
  final String? itemThumbnail;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.itemType,
    required this.referenceId,
    this.quantity = 1,
    required this.priceAtPurchase,
    required this.visitDate,
    this.ticketCode,
    this.isRedeemed = false,
    this.redeemedAt,
    this.itemName,
    this.itemThumbnail,
  });

  String get subtotalString {
    final subtotal = priceAtPurchase * quantity;
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      itemType: ItemType.fromString(json['item_type'] as String),
      referenceId: json['reference_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      visitDate: DateTime.parse(json['visit_date'] as String),
      ticketCode: json['ticket_code'] as String?,
      isRedeemed: json['is_redeemed'] as bool? ?? false,
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'] as String)
          : null,
      itemName: json['item_name'] as String?,
      itemThumbnail: json['item_thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_type': itemType.name,
      'reference_id': referenceId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'visit_date': visitDate.toIso8601String().split('T')[0],
      'ticket_code': ticketCode,
      'is_redeemed': isRedeemed,
      'redeemed_at': redeemedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'TransactionItemModel(id: $id, type: $itemType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
