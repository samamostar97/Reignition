using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasIndex(x => x.Username).IsUnique().HasFilter("IsDeleted = 0");
        builder.HasIndex(x => x.Email).IsUnique().HasFilter("IsDeleted = 0");

        builder.Property(x => x.Username).HasMaxLength(50).IsRequired();
        builder.Property(x => x.FirstName).HasMaxLength(50).IsRequired();
        builder.Property(x => x.LastName).HasMaxLength(50).IsRequired();
        builder.Property(x => x.Email).HasMaxLength(150).IsRequired();
        builder.Property(x => x.PasswordHash).IsRequired();
        builder.Property(x => x.PhoneNumber).HasMaxLength(20);
        builder.Property(x => x.ProfileImageUrl).HasMaxLength(500);

        builder.HasQueryFilter(x => !x.IsDeleted);
    }
}
