using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Core.Entities;
using Reignition.Core.Enums;

namespace Reignition.Infrastructure.Data;

public static class SeedService
{
    public static async Task SeedAsync(ReignitionDbContext context)
    {
        var now = DateTimeUtils.UtcNow;

        if (!await context.Users.AnyAsync())
        {
            context.Users.Add(new User
            {
                Username = "desktop",
                FirstName = "Admin",
                LastName = "Reignition",
                Email = "admin@reignition.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Role = Role.Admin,
                IsActive = true,
                CreatedAt = now
            });

            await context.SaveChangesAsync();
        }

        if (!await context.MembershipTypes.AnyAsync())
        {
            context.MembershipTypes.AddRange(
                new MembershipType
                {
                    Name = "Mjesečna",
                    Description = "Standardna mjesečna članarina za pristup teretani.",
                    DurationInDays = 30,
                    Price = 50.00m,
                    IsActive = true,
                    CreatedAt = now
                },
                new MembershipType
                {
                    Name = "Tromjesečna",
                    Description = "Tromjesečna članarina sa popustom.",
                    DurationInDays = 90,
                    Price = 120.00m,
                    IsActive = true,
                    CreatedAt = now
                },
                new MembershipType
                {
                    Name = "Godišnja",
                    Description = "Godišnja članarina sa najvećim popustom.",
                    DurationInDays = 365,
                    Price = 400.00m,
                    IsActive = true,
                    CreatedAt = now
                }
            );

            await context.SaveChangesAsync();
        }

        // Seed member users and memberships
        var memberCount = await context.Users.CountAsync(u => u.Role == Role.Member);
        if (memberCount == 0)
        {
            var types = await context.MembershipTypes.ToListAsync();
            var monthly = types.First(t => t.Name == "Mjesečna");
            var quarterly = types.First(t => t.Name == "Tromjesečna");
            var yearly = types.First(t => t.Name == "Godišnja");

            var members = new List<User>();
            var seedMembers = new[]
            {
                ("amar.h", "Amar", "Hadžić", "amar@example.com", "061234567"),
                ("emina.k", "Emina", "Kovačević", "emina@example.com", "062345678"),
                ("tarik.m", "Tarik", "Mujić", "tarik@example.com", "063456789"),
                ("lejla.b", "Lejla", "Begović", "lejla@example.com", "064567890"),
                ("adnan.s", "Adnan", "Salihović", "adnan@example.com", "065678901"),
                ("amra.d", "Amra", "Delić", "amra@example.com", "061111222"),
                ("haris.c", "Haris", "Čengić", "haris@example.com", "062222333"),
                ("selma.z", "Selma", "Zukić", "selma@example.com", "063333444"),
                ("edin.r", "Edin", "Ramić", "edin@example.com", "064444555"),
                ("naida.p", "Naida", "Pašić", "naida@example.com", "065555666"),
                ("mirza.t", "Mirza", "Turković", "mirza@example.com", "061666777"),
                ("jasmina.g", "Jasmina", "Ganić", "jasmina@example.com", "062777888"),
                ("armin.i", "Armin", "Imamović", "armin@example.com", "063888999"),
                ("dina.o", "Dina", "Osmić", "dina@example.com", "064999000"),
                ("kenan.f", "Kenan", "Fejzić", "kenan@example.com", "065000111"),
            };

            foreach (var (username, first, last, email, phone) in seedMembers)
            {
                members.Add(new User
                {
                    Username = username,
                    FirstName = first,
                    LastName = last,
                    Email = email,
                    PhoneNumber = phone,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    IsActive = true,
                    CreatedAt = now.AddDays(-Random.Shared.Next(10, 90))
                });
            }

            // Make 2 members inactive
            members[13].IsActive = false;
            members[14].IsActive = false;

            context.Users.AddRange(members);
            await context.SaveChangesAsync();

            // Create memberships with varied statuses
            var memberships = new List<Membership>();

            // Active monthly (5 members) — started recently
            for (var i = 0; i < 5; i++)
            {
                var startDate = now.AddDays(-Random.Shared.Next(1, 20));
                memberships.Add(new Membership
                {
                    UserId = members[i].Id,
                    MembershipTypeId = monthly.Id,
                    StartDate = startDate,
                    EndDate = startDate.AddDays(monthly.DurationInDays),
                    Status = MembershipStatus.Active,
                    CreatedAt = startDate
                });
            }

            // Active quarterly (3 members)
            for (var i = 5; i < 8; i++)
            {
                var startDate = now.AddDays(-Random.Shared.Next(10, 60));
                memberships.Add(new Membership
                {
                    UserId = members[i].Id,
                    MembershipTypeId = quarterly.Id,
                    StartDate = startDate,
                    EndDate = startDate.AddDays(quarterly.DurationInDays),
                    Status = MembershipStatus.Active,
                    CreatedAt = startDate
                });
            }

            // Expiring soon — active but end date within 7 days (3 members)
            for (var i = 8; i < 11; i++)
            {
                var endDate = now.AddDays(Random.Shared.Next(1, 7));
                var startDate = endDate.AddDays(-monthly.DurationInDays);
                memberships.Add(new Membership
                {
                    UserId = members[i].Id,
                    MembershipTypeId = monthly.Id,
                    StartDate = startDate,
                    EndDate = endDate,
                    Status = MembershipStatus.Active,
                    CreatedAt = startDate
                });
            }

            // Expired (2 members)
            for (var i = 11; i < 13; i++)
            {
                var startDate = now.AddDays(-60);
                memberships.Add(new Membership
                {
                    UserId = members[i].Id,
                    MembershipTypeId = monthly.Id,
                    StartDate = startDate,
                    EndDate = startDate.AddDays(monthly.DurationInDays),
                    Status = MembershipStatus.Expired,
                    CreatedAt = startDate
                });
            }

            // Cancelled (2 inactive members)
            for (var i = 13; i < 15; i++)
            {
                var startDate = now.AddDays(-45);
                memberships.Add(new Membership
                {
                    UserId = members[i].Id,
                    MembershipTypeId = yearly.Id,
                    StartDate = startDate,
                    EndDate = startDate.AddDays(yearly.DurationInDays),
                    Status = MembershipStatus.Cancelled,
                    CreatedAt = startDate
                });
            }

            context.Memberships.AddRange(memberships);
            await context.SaveChangesAsync();

            // Seed payments for each membership
            var methods = new[] { PaymentMethod.Cash, PaymentMethod.Card, PaymentMethod.BankTransfer };
            var payments = new List<Payment>();

            foreach (var membership in memberships)
            {
                var membershipType = types.First(t => t.Id == membership.MembershipTypeId);
                payments.Add(new Payment
                {
                    UserId = membership.UserId,
                    MembershipId = membership.Id,
                    Amount = membershipType.Price,
                    PaymentMethod = methods[Random.Shared.Next(methods.Length)],
                    TransactionDate = membership.CreatedAt,
                    Status = membership.Status == MembershipStatus.Cancelled
                        ? PaymentStatus.Refunded
                        : PaymentStatus.Completed,
                    Note = membership.Status == MembershipStatus.Cancelled
                        ? "Refundirano zbog otkazivanja."
                        : null,
                    CreatedAt = membership.CreatedAt
                });
            }

            context.Payments.AddRange(payments);
            await context.SaveChangesAsync();
        }
    }
}
