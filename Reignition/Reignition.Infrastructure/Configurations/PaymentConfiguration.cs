using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Configurations;

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Membership)
            .WithMany()
            .HasForeignKey(x => x.MembershipId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.Amount).HasPrecision(10, 2);
        builder.Property(x => x.Note).HasMaxLength(500);

        builder.HasQueryFilter(x => !x.IsDeleted);
    }
}
