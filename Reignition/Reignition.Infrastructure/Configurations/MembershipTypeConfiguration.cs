using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Configurations;

public class MembershipTypeConfiguration : IEntityTypeConfiguration<MembershipType>
{
    public void Configure(EntityTypeBuilder<MembershipType> builder)
    {
        builder.HasIndex(x => x.Name).IsUnique().HasFilter("IsDeleted = 0");

        builder.Property(x => x.Name).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(500);
        builder.Property(x => x.Price).HasPrecision(10, 2);

        builder.HasQueryFilter(x => !x.IsDeleted);
    }
}
