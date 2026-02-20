using Reignition.Application.Common;
using Reignition.Core.Enums;

namespace Reignition.Application.Filters;

public class PaymentQueryFilter : PaginationRequest
{
    public PaymentMethod? PaymentMethod { get; set; }
    public PaymentStatus? Status { get; set; }
    public DateTime? DateFrom { get; set; }
    public DateTime? DateTo { get; set; }
}
