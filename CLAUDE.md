# Reignition — Agent Rules (CLAUDE.md)

## 📖 How To Use This Template

1. **Find & Replace** `Reignition` → your project display name (e.g., "FixFlow")
2. **Find & Replace** `Reignition` → your solution/folder name, PascalCase (e.g., "FixFlow")
3. **Find & Replace** `reignition` → lowercase snake_case name (e.g., "fixflow")
4. **Find & Replace** `{Entity}` / `{entity}` → specific entity names when writing examples
5. **Fill in** `gym management platform with e-commerce (supplement sales), trainer/nutritionist booking, user progress tracking, and ML-powered supplement recommendations` in Core Philosophy
6. **Fill in** timezone IDs in DateTimeUtils section — or keep `Europe/Sarajevo` defaults
7. **Fill in** color values in `CLAUDE-UI.md` Theme section after discussing with your team
8. **Review** Docker, Messaging, Worker, Real-Time sections — leave as "NE DIRATI" until ready
9. **Pair this file** with `CLAUDE-UI.md` — agent reads UI rules from there when doing frontend work

> **Agent instruction:** When working on UI screens or components, ALSO read `CLAUDE-UI.md` for design rules, theme, spacing, and reference apps. Both files are active rules.

---

## 🎯 Core Philosophy

You are working on **Reignition** — a gym management platform with e-commerce (supplement sales), trainer/nutritionist booking, user progress tracking, and ML-powered supplement recommendations. The project uses:
- **.NET 8 Web API** backend with **Clean Architecture** (SQL Server)
- **Flutter desktop app** (Windows) — admin dashboard
- **Flutter mobile app** — user-facing
- **Shared Flutter package** (`reignition_core`) for API communication, models, and services
- **Riverpod** (Notifier/AsyncNotifier pattern) for state management on both Flutter apps

Every piece of code must be modular, testable, and maintainable. You prioritize separation of concerns over convenience.

**Zlatno pravilo: Ako moraš skrolati da razumiješ šta nešto radi — predugačko je.**

---

## 🌐 Language Rule

- **UI tekst, validacione poruke, error poruke, snackbari, dialog tekst** → bosanski
- **Kod, komentari, varijable, klase, git commit poruke** → engleski
- **Ovo je eksplicitno pravilo, ne preferencija.** Agent nikad ne miješa — bosanski za korisnika, engleski za kod.

---

## 🏗️ Project Structure

```
Reignition/
│
├── packages/
│   └── reignition_core/lib/             # SHARED Flutter package
│       ├── api/                        # Singleton HTTP client, base URL config
│       ├── models/
│       │   ├── common/                 # PagedResult<T>, LookupResponse, pagination helpers
│       │   ├── filters/                # *QueryFilter with toQueryParameters()
│       │   ├── requests/               # *Request — nullable fields, conditional toJson()
│       │   └── responses/              # *Response — fromJson() factory
│       ├── services/                   # CrudService<T> base + domain services
│       ├── storage/                    # TokenStorage (FlutterSecureStorage)
│       ├── helpers/                    # DateFormatter, CurrencyFormatter, StringExtensions, EnumHelper, FileHelper, PaginationHelper
│       └── validators/                 # FormValidators — reusable validation rules
│
├── reignition_desktop/lib/              # FLUTTER ADMIN DASHBOARD (Windows)
│   ├── constants/                      # AppSizes, AppSpacing, AppTextStyles
│   ├── providers/                      # ListNotifier<T> pattern, ListState<T>
│   ├── screens/                        # *Screen suffix, scaffold + body
│   ├── utils/
│   └── widgets/
│       ├── layout/                     # ResponsiveLayout, AppScaffold
│       └── shared/                     # Buttons, cards, form fields, dialogs
│
├── reignition_mobile/lib/               # FLUTTER MOBILE APP
│   ├── config/
│   ├── constants/
│   ├── models/                         # LITE models (simplified for mobile UI)
│   ├── providers/
│   ├── screens/
│   ├── utils/
│   └── widgets/
│       ├── layout/                     # MobileScaffold, SafeAreaWrapper
│       └── shared/
│
└── Reignition/                          # .NET 8 WEB API BACKEND
    ├── Reignition.Core/                 # Domain — pure entities (all extend BaseEntity), enums
    ├── Reignition.Application/          # Contracts — DTOs, Filters, IServices, IRepositories, Helpers, Exceptions
    │   └── Common/                     # PagedResult<T>, PaginationRequest, DateTimeUtils, LookupResponse
    ├── Reignition.Infrastructure/       # Implementations — Services, Repos, EF Configs, Mapster, Migrations
    ├── Reignition.API/                  # Entry point — Controllers, DI Extensions, Middleware
    ├── Reignition.Messaging/            # Message contracts (RabbitMQ/MassTransit) — NE DIRATI DOK NIJE SPREMNO
    └── Reignition.Worker/               # Background workers — NE DIRATI DOK NIJE SPREMNO
```

---

## 📍 Where Does Code Go?

| Šta praviš | Gdje ide |
|---|---|
| Entity (extend BaseEntity) | `Core/Entities/` |
| Enum | `Core/Enums/` |
| CreateRequest DTO (Data Annotations) | `Application/DTOs/Request/` |
| UpdateRequest DTO (ALL NULLABLE) | `Application/DTOs/Request/` |
| Response DTO | `Application/DTOs/Response/` |
| LookupResponse | `Application/Common/` (reusable `{Id, Name}`) |
| QueryFilter (extend PaginationRequest) | `Application/Filters/` |
| Helper (slug, code gen, DateTimeUtils) | `Application/Helpers/` · `Application/Common/` |
| Service/Repository interfejs | `Application/IServices/` · `Application/IRepositories/` |
| Service impl (Validate/Prepare/After hooks) | `Infrastructure/Services/` |
| Repository impl | `Infrastructure/Repositories/` |
| EF Configuration (Fluent API) | `Infrastructure/Configurations/` |
| Mapster profil | `Infrastructure/Mapping/MappingConfig.cs` |
| Controller | `API/Controllers/` |
| DI registracija | `API/Extensions/` |
| Flutter Response model (fromJson) | `core/models/responses/` |
| Flutter Request models (toJson) | `core/models/requests/` |
| Flutter QueryFilter (toQueryParameters) | `core/models/filters/` |
| Flutter PagedResult, LookupResponse | `core/models/common/` |
| Flutter shared service | `core/services/` |
| Flutter validator / helper | `core/validators/` · `core/helpers/` |
| Desktop provider / screen / widget | `desktop/providers/` · `desktop/screens/` · `desktop/widgets/` |
| Mobile provider / screen / widget | `mobile/providers/` · `mobile/screens/` · `mobile/widgets/` |
| Mobile LITE model | `mobile/models/` |

---

## ⚙️ Critical Architecture Rules

1. **`reignition_core` je JEDINI paket koji komunicira sa API-jem.** Call chain: `Widget → Provider → Service (core) → ApiClient`. Nikad preskakati slojeve.
2. **Models u core moraju odgovarati DTOs na backendu.** Request ↔ DTOs/Request, Response ↔ DTOs/Response, Filter ↔ Filters. Vidjeti **Contract Sync** sekciju.
3. **Core NEMA zavisnosti** — čisti entiteti (svi extend BaseEntity) i enumi.
4. **Application definiše interfejse**, Infrastructure ih implementira. **DateTimeUtils živi u Application/Common/**, ne Infrastructure.
5. **Desktop i mobile imaju ODVOJENE providere i UI** — dijele samo core paket. Mobile može imati LITE modele (vidjeti sekciju ispod).
6. **Soft delete svugdje** — `IsDeleted` flag, nikad fizičko brisanje. `BaseRepository.AsQueryable()` automatski filtrira.
7. **DateTime uvijek kroz DateTimeUtils** — NIKAD `DateTime.Now` direktno. UTC za storage, local za display. Vidjeti **DateTimeUtils** sekciju.
8. **Mapping isključivo Mapster** — NE AutoMapper. Custom mape u `MappingConfig.cs`.
9. **Exception poruke user-facing** (bosanski) — ExceptionHandlerMiddleware ih mapira na HTTP status kodove.
10. **[Authorize] obavezan** na svaki controller endpoint sa odgovarajućim rolama.
11. **Ne mora svaki servis nasljeđivati BaseService, niti svaki controller BaseController** — samo kad ima smisla za standardni CRUD.
12. **Svaki novi feature mora proći backend → core → frontend flow** — nikad frontend bez backend podrške.
13. **SQL Server** je database. EF Core sa Fluent API konfiguracijama.
14. **Lookup endpointi** za dropdown-e — `GET /api/{entities}/lookup` vraća `List<LookupResponse>` bez paginacije.
15. **BaseEntity** sadrži: `Id`, `CreatedAt`, `UpdatedAt`, `IsDeleted`, `CreatedBy`, `UpdatedBy`. DbContext automatski setuje audit polja iz `HttpContext.User`.

---

## 🧱 Backend Foundation Classes

> Ove klase su temelj backend arhitekture. Agent ih MORA poznavati jer svaki novi entitet, servis i controller nasljeđuje ili koristi ove bazne klase.

### BaseEntity — `Core/Entities/BaseEntity.cs`

```csharp
namespace Reignition.Core.Entities;

public abstract class BaseEntity
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
    public int? CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
}
```

Svaki entitet MORA nasljeđivati `BaseEntity`. Audit polja (`CreatedAt`, `UpdatedAt`, `CreatedBy`, `UpdatedBy`) se automatski setuju — `CreatedAt`/`UpdatedAt` u BaseRepository, `CreatedBy`/`UpdatedBy` u DbContext `SaveChangesAsync` override iz `HttpContext.User`.

### IRepository — `Application/IRepositories/IRepository.cs`

```csharp
namespace Reignition.Application.IRepositories;

public interface IRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(int id);
    Task<List<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);
    IQueryable<T> AsQueryable();
}
```

### BaseRepository — `Infrastructure/Repositories/BaseRepository.cs`

```csharp
namespace Reignition.Infrastructure.Repositories;

public class BaseRepository<T> : IRepository<T> where T : BaseEntity
{
    protected readonly ReignitionDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public BaseRepository(ReignitionDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(int id)
        => await _dbSet.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);

    public async Task<List<T>> GetAllAsync()
        => await _dbSet.Where(x => !x.IsDeleted).ToListAsync();

    public async Task AddAsync(T entity)
    {
        entity.CreatedAt = DateTimeUtils.UtcNow;
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(T entity)
    {
        entity.UpdatedAt = DateTimeUtils.UtcNow;
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(T entity)
    {
        entity.IsDeleted = true;
        entity.UpdatedAt = DateTimeUtils.UtcNow;
        await _context.SaveChangesAsync();
    }

    public IQueryable<T> AsQueryable()
        => _dbSet.Where(x => !x.IsDeleted).AsQueryable();
}
```

**Ključno:** `AsQueryable()` i `GetByIdAsync()` automatski filtriraju `IsDeleted`. Servisi NIKAD ne trebaju ručno filtrirati soft-deleted entitete.

### IBaseService — `Application/IServices/IBaseService.cs`

```csharp
namespace Reignition.Application.IServices;

public interface IBaseService<TResponse, TCreate, TUpdate, TFilter>
    where TFilter : PaginationRequest
{
    Task<PagedResult<TResponse>> GetAllAsync(TFilter filter);
    Task<TResponse> GetByIdAsync(int id);
    Task<TResponse> CreateAsync(TCreate dto);
    Task<TResponse> UpdateAsync(int id, TUpdate dto);
    Task DeleteAsync(int id);
    Task<List<LookupResponse>> GetLookupAsync();
}
```

### BaseService — `Infrastructure/Services/BaseService.cs`

```csharp
namespace Reignition.Infrastructure.Services;

public abstract class BaseService<TEntity, TResponse, TCreate, TUpdate, TFilter>
    : IBaseService<TResponse, TCreate, TUpdate, TFilter>
    where TEntity : BaseEntity
    where TFilter : PaginationRequest
{
    protected readonly IRepository<TEntity> _repository;

    protected BaseService(IRepository<TEntity> repository)
    {
        _repository = repository;
    }

    public virtual async Task<PagedResult<TResponse>> GetAllAsync(TFilter filter)
    {
        var query = _repository.AsQueryable();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<TResponse>
        {
            Items = items.Adapt<List<TResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize
        };
    }

    public virtual async Task<TResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        return entity.Adapt<TResponse>();
    }

    public virtual async Task<TResponse> CreateAsync(TCreate dto)
    {
        var entity = dto.Adapt<TEntity>();
        await ValidateCreateAsync(entity, dto);
        await PrepareCreateAsync(entity, dto);
        await _repository.AddAsync(entity);
        await AfterCreateAsync(entity, dto);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdate dto)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        await ValidateUpdateAsync(entity, dto);
        dto.Adapt(entity);  // Mapster in-place mapping
        await PrepareUpdateAsync(entity, dto);
        await _repository.UpdateAsync(entity);
        await AfterUpdateAsync(entity, dto);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task DeleteAsync(int id)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        await ValidateDeleteAsync(entity);
        await _repository.DeleteAsync(entity);
        await AfterDeleteAsync(entity);
    }

    public virtual async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Select(x => new LookupResponse { Id = x.Id })
            .ToListAsync();
    }

    // ── ApplyFilter — override u svakom servisu za Include, search, sort ──
    protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TFilter filter)
        => query.OrderByDescending(x => x.CreatedAt);

    // ── Hookovi — override samo kad treba (vidjeti Service Hook Pattern sekciju) ──
    protected virtual Task ValidateCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task ValidateUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task ValidateDeleteAsync(TEntity entity) => Task.CompletedTask;
    protected virtual Task PrepareCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task PrepareUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task AfterCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task AfterUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task AfterDeleteAsync(TEntity entity) => Task.CompletedTask;
}
```

**Ključno:**
- Mapping koristi **Mapster** (`dto.Adapt<TEntity>()`, `entity.Adapt<TResponse>()`). NIKAD AutoMapper.
- `UpdateAsync` koristi `dto.Adapt(entity)` — in-place mapping koji ažurira samo non-null polja iz Update DTO.
- `GetLookupAsync()` je base implementacija — override u servisu da doda `Name` mapping specifično za entitet.
- **Servisi koriste Repository, NIKAD direktno DbContext.**
- Svaki od 8 hookova je `virtual Task.CompletedTask` — override samo kad treba.

### BaseController — `API/Controllers/BaseController.cs`

```csharp
namespace Reignition.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public abstract class BaseController<TResponse, TCreate, TUpdate, TFilter> : ControllerBase
    where TFilter : PaginationRequest
{
    protected readonly IBaseService<TResponse, TCreate, TUpdate, TFilter> _service;

    protected BaseController(IBaseService<TResponse, TCreate, TUpdate, TFilter> service)
    {
        _service = service;
    }

    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetAll([FromQuery] TFilter filter)
        => Ok(await _service.GetAllAsync(filter));

    [HttpGet("{id}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id)
        => Ok(await _service.GetByIdAsync(id));

    [HttpPost]
    public virtual async Task<ActionResult<TResponse>> Create([FromBody] TCreate dto)
        => Ok(await _service.CreateAsync(dto));

    [HttpPut("{id}")]
    public virtual async Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdate dto)
        => Ok(await _service.UpdateAsync(id, dto));

    [HttpDelete("{id}")]
    public virtual async Task<ActionResult> Delete(int id)
    {
        await _service.DeleteAsync(id);
        return NoContent();
    }

    [HttpGet("lookup")]
    public virtual async Task<ActionResult<List<LookupResponse>>> GetLookup()
        => Ok(await _service.GetLookupAsync());
}
```

**Pravila:**
- Controller je THIN — prima request, poziva servis, vraća response. Zero business logike.
- `[Authorize]` na klasi = svi endpointi zahtijevaju auth. Override per-endpoint za specifične role: `[Authorize(Roles = "Admin")]`.
- **Ne mora svaki controller nasljeđivati BaseController** — samo standardni CRUD. Ako controller ima nestandardne endpoint-e, napravi ga od nule sa `ControllerBase`.
- Endpointi koji trebaju `[FromForm]` (file upload) ili nestandardnu logiku — override `virtual` metodu ili dodaj novi endpoint.

### ExceptionHandlerMiddleware — `API/Middleware/ExceptionHandlerMiddleware.cs`

```csharp
namespace Reignition.API.Middleware;

public class ExceptionHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlerMiddleware> _logger;

    public ExceptionHandlerMiddleware(RequestDelegate next, ILogger<ExceptionHandlerMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var statusCode = exception switch
        {
            KeyNotFoundException          => (int)HttpStatusCode.NotFound,           // 404
            ConflictException             => (int)HttpStatusCode.Conflict,           // 409
            EntityHasDependentsException  => (int)HttpStatusCode.Conflict,           // 409
            ForbiddenException            => (int)HttpStatusCode.Forbidden,          // 403
            UnauthorizedAccessException   => (int)HttpStatusCode.Unauthorized,       // 401
            InvalidOperationException     => (int)HttpStatusCode.BadRequest,         // 400
            ArgumentException             => (int)HttpStatusCode.BadRequest,         // 400
            NotSupportedException         => (int)HttpStatusCode.NotImplemented,     // 501
            _                             => (int)HttpStatusCode.InternalServerError // 500
        };

        // Loguj SAMO 500 — ostale exception-e korisnik TREBA vidjeti
        if (statusCode == (int)HttpStatusCode.InternalServerError)
            _logger.LogError(exception, "Unhandled exception occurred");

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;

        var response = new
        {
            error = statusCode == (int)HttpStatusCode.InternalServerError
                ? "Došlo je do greške na serveru."  // NIKAD stack trace korisniku
                : exception.Message,                // Bosanska poruka iz servisa
            statusCode
        };

        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
```

### Custom Exceptions — `Application/Exceptions/`

```csharp
// ConflictException.cs — duplikat, unique constraint violation
public class ConflictException : Exception
{
    public ConflictException(string message) : base(message) { }
}

// EntityHasDependentsException.cs — pokušaj brisanja entiteta sa zavisnostima
public class EntityHasDependentsException : Exception
{
    public EntityHasDependentsException(string entityName, string dependentName)
        : base($"Ne možete obrisati {entityName} jer ima povezane {dependentName}.") { }
}

// ForbiddenException.cs — korisnik nema dozvolu
public class ForbiddenException : Exception
{
    public ForbiddenException(string message = "Nemate dozvolu za ovu akciju.") : base(message) { }
}
```

**Exception pravila:**
- Poruke su UVIJEK bosanski (user-facing) — middleware ih proslijeđuje korisniku
- 500 error: middleware zamijeni poruku generickom — NIKAD stack trace
- Dodaj nove custom exception-e po potrebi (npr. `PaymentException`, `FileUploadException`)
- Frontend `ApiException.fromResponse()` parsira `{ "error": "...", "statusCode": ... }` format

---

## 🌐 API URL Conventions

### Route Rules

- **Plural resursi:** `/api/orders`, `/api/categories` — NIKAD singular
- **Kebab-case za multi-word:** `/api/repair-requests`, `/api/job-categories`
- **Nested resursi samo za strong ownership:** `/api/orders/{orderId}/items` — stavke ne postoje bez narudžbe
- **Flat za weak relations:** `/api/reviews?technicianId=5` — NE `/api/technicians/5/reviews`
- **Lookup uvijek na root:** `/api/categories/lookup`

| Operacija | Metod | Ruta | Body |
|---|---|---|---|
| Lista (paginirana) | GET | `/api/{entities}` | QueryString |
| Detalj | GET | `/api/{entities}/{id}` | — |
| Lookup (dropdown) | GET | `/api/{entities}/lookup` | — |
| Kreiranje | POST | `/api/{entities}` | JSON body |
| Ažuriranje | PUT | `/api/{entities}/{id}` | JSON body |
| Brisanje | DELETE | `/api/{entities}/{id}` | — |
| Bulk operacija | POST | `/api/{entities}/bulk-{action}` | JSON body |

### Versioning

- **V1 implicitno** — ne treba `/api/v1/` dok nema breaking changes
- Kad bude breaking change → `/api/v2/{entities}` za nove, stari ostaju
- Controller atribut: `[Route("api/[controller]")]`

---

## 📦 Mobile LITE Models

LITE modeli žive u `mobile/models/` i služe kad full Response model ne odgovara mobilnom UI-ju.

**Kreiraj LITE model kada:**
- Response ima 10+ polja, a mobile koristi samo 3-5
- Mobile treba flattened strukturu (npr. `technicianName` umjesto nested `technician.user.name`)
- Mobile treba computed/derived polja specifična za UI (npr. `distanceFormatted`, `isUrgent`)
- Isti entitet ima drastično različit prikaz na desktop vs mobile

**Koristi core Response kada:**
- Mobile koristi većinu polja iz Response-a
- Nema potrebe za flatteningom ili computed poljima

### Pattern

```dart
// mobile/models/order_lite.dart
class OrderLite {
  final int id;
  final String code;
  final String statusDisplay;
  final String customerName;  // flattened iz nested Customer.User.Name
  final bool isUrgent;        // computed

  factory OrderLite.fromResponse(OrderResponse response) => OrderLite(
    id: response.id,
    code: response.code,
    statusDisplay: EnumHelper.getDisplayName(response.status),
    customerName: response.customerName,
    isUrgent: response.status == OrderStatus.pending &&
      DateTime.now().difference(response.createdAt).inHours < 1,
  );
}
```

---

## 📏 Code Limits & Modularity

### Flutter Limiti

| Šta | Limit | Zašto |
|---|---|---|
| `build()` metoda | ~50 linija | Čitljiva na prvi pogled |
| Screen widget (orchestrator) | ~80 linija | Samo slaže dijelove, nema logike |
| Pojedinačni UI widget fajl | ~120 linija | Jedna vizualna odgovornost |
| Notifier/Provider klasa | ~200 linija | Jedan domenski koncept |
| Model klasa | ~200 linija | Koliko treba |
| Core servis | ~150 linija | Jedan resource |
| Widget nesting | max 4 nivoa | Dublje = nečitljivo |
| Uslovni nesting | max 2 nivoa | Koristi early return |
| Parametri konstruktora | 5-6 | Više = treba grupisati |

**Ako fajl pređe 250 linija — zastani i razmisli.**

### .NET Backend — Principi Umjesto Linija

- **Controller** — NE SMIJE imati business logiku. Thin: primi request → pozovi servis → vrati response.
- **Service** — jedna domenska cjelina. Razdvajaj kad metode nemaju veze sa domenom, NE po broju linija.
- **Repository** — BaseRepository radi 90% posla. Ako raste, metode vjerovatno pripadaju servisu.
- **Metode** — jedna operacija. NE razbijaj na `_step1()`, `_step2()` koje se zovu jednom.

### Nesting — Early Return Always

```dart
// ❌ if (user != null) { if (user.isActive) { if (user.hasSubscription) { ... } } }
// ✅ Early return
if (user == null) return;
if (!user.isActive) return;
if (!user.hasSubscription) return;
// happy path...
```

---

## 🔄 Implementation Flow — 5 Faza (OBAVEZNO)

Svaki novi feature prolazi kroz 5 faza. Agent NIKAD ne preskače fazu niti nastavlja bez checkpointa.

### Faza 1 — Planiranje (PRIJE KODA)

1. Razumij feature zahtjev — šta korisnik želi **postići**, ne kako
2. Definiši entitete i relacije — navigation properties, FK-ovi
3. Definiši DTOs — koji fieldovi, koji required, koji nullable, validaciona pravila
4. Definiši API endpoint-e — rute (vidjeti **API URL Conventions**), HTTP metode, role za `[Authorize]`
5. Definiši lookup-e — koji dropdown-i trebaju, koji lookup endpointi

**🛑 CHECKPOINT — prezentiraj plan korisniku. NE piši kod dok korisnik ne potvrdi.**

### Faza 2 — Backend (.NET)

1. Entity (extend BaseEntity) → `Core/Entities/`
2. Enum (if needed) → `Core/Enums/`
3. EF Configuration (Fluent API) → `Infrastructure/Configurations/`
4. **Migration — PITAJ za odobrenje prije kreiranja**
5. CreateRequest DTO (Data Annotations, bosanske poruke) → `Application/DTOs/Request/`
6. UpdateRequest DTO (ALL NULLABLE) → `Application/DTOs/Request/`
7. Response DTO → `Application/DTOs/Response/`
8. QueryFilter (extend PaginationRequest) → `Application/Filters/`
9. IService → `Application/IServices/`
10. Mapster mapping → `Infrastructure/Mapping/MappingConfig.cs`
11. Repository (if custom needed) → `Infrastructure/Repositories/`
12. Service (Validate/Prepare/After hooks) → `Infrastructure/Services/`
13. Controller ([Authorize] per endpoint) → `API/Controllers/`
14. Lookup endpoint (if FK relations) → isti controller
15. DI Registration → `API/Extensions/`

**Testiraj endpoint-e (Swagger/Postman) prije nego ideš dalje.**

**🛑 CHECKPOINT — izvijesti šta je kreirano, pitaj za review.**

### Faza 3 — Core (shared Flutter package)

1. Response model (fromJson) — **MORA odgovarati backend Response DTO, svako polje**
2. CreateRequest (toJson) — **MORA imati iste validacije kao backend Data Annotations**
3. UpdateRequest (nullable, conditional toJson) — **nullable polja moraju odgovarati**
4. QueryFilter (toQueryParameters) — **isti parametri kao backend filter**
5. LookupResponse (if needed) — u `core/models/common/`
6. Service (extends CrudService)

**⚠️ Izvrši Contract Sync provjeru (vidjeti sekciju ispod).**

**🛑 CHECKPOINT**

### Faza 4 — Frontend (Desktop / Mobile)

1. **Pročitaj `CLAUDE-UI.md`** za design pravila, temu, spacing, i reference
2. **UI Mini-Plan (OBAVEZNO PRIJE KODA)** — za svaki screen napiši kratki plan i čekaj OK:
   - Koje kolone/polja se prikazuju (od svih dostupnih u Response)
   - Koji layout (tabela, kartice, lista)
   - Koje akcije (row click → modal ili navigacija, inline edit ili forma)
   - Koja referenca iz Design Reference tabele se koristi
   - Primjer:
     ```
     OrderListScreen plan:
     - Tabela: Code, Customer, Status (badge), Total, CreatedAt
     - Stripe stil, filter chips iznad (status, date range)
     - Row click → detail modal
     - Forma: Mercury stil, side-panel
     OK?
     ```
3. **🛑 MINI-CHECKPOINT — čekaj potvrdu plana prije kodiranja**
4. Provider (Notifier pattern)
5. Screen (orchestrator, ~80 linija)
6. Widgets (form, table, cards)
7. **Forme MORAJU imati ISTE validacije kao backend**
8. Error handling mora pokriti sve backend exception-e
9. Responsiveness provjera

**🛑 CHECKPOINT**

### Faza 5 — Verifikacija

1. Test full flow: create → read → update → delete
2. Test edge case-ove: duplikat, invalid input, unauthorized, empty state
3. Test responsiveness na min/max širinama
4. **Finalni Contract Sync check**

---

## 🔗 Backend ↔ Frontend Contract Sync (CRITICAL)

**Svaki put kad se radi na jednom sloju, PROVJERI usklađenost sa drugim.**

### Šta MORA biti sinhronizovano

| Aspekt | Backend | Frontend |
|---|---|---|
| **Response polja** | `{Entity}Response` DTO | `{Entity}Response.fromJson()` — svako polje, isti tipovi |
| **Request polja** | `Create{Entity}Request` | `Create{Entity}Request.toJson()` — ista polja |
| **Nullable polja** | `string? Name` u UpdateDTO | `String? name` u UpdateRequest — oba nullable |
| **Validacija** | `[StringLength(100, MinimumLength = 2)]` | `FormValidators.length(v, min: 2, max: 100)` — ISTE vrijednosti |
| **Required** | `[Required]` na polju | `FormValidators.required()` u formi |
| **Enumi** | `enum OrderStatus { Pending, Confirmed }` | Identičan enum sa istim vrijednostima |
| **Error poruke** | `"Naziv mora imati najmanje 2 karaktera."` | Ista poruka u frontend validatoru |
| **Pagination** | `PagedResult<T>` sa `Items, TotalCount, PageNumber` | Flutter `PagedResult<T>` sa identičnim poljima |
| **Query parametri** | `PaginationRequest` + `QueryFilter` polja | `BaseQueryFilter.toQueryParameters()` šalje iste parametre |
| **Lookup** | `GET /api/{entities}/lookup` → `List<LookupResponse>` | Frontend dropdown koristi isti endpoint i model |
| **HTTP status kodovi** | `ConflictException` → 409 | `ApiException.isConflict` → prikazuje poruku |
| **Error format** | `{ "error": "Poruka", "statusCode": 409 }` | `ApiException.fromResponse()` parsira isti format |

### Kad se doda novo polje na backendu

1. Dodaj u Entity
2. Dodaj u Response DTO
3. Dodaj u Create/Update Request DTO (sa validacijom)
4. **Dodaj u Flutter Response model** (fromJson)
5. **Dodaj u Flutter Request modele** (toJson, sa ISTOM validacijom)
6. **Dodaj u Flutter formu** (novi field sa validatorom)

**Nikad ne završi samo backend promjenu bez da provjeriš/ažuriraš frontend modele.**

---

## ⏱️ DateTimeUtils — Centralizirano Vrijeme sa Timezone Podrškom

### Backend — `Application/Common/DateTimeUtils.cs`

```csharp
namespace Reignition.Application.Common;

public static class DateTimeUtils
{
    // ── Timezone Configuration ──────────────────────────────────────
    // Linux/macOS koriste IANA ID, Windows koriste Windows ID.
    // Zamijeni sa timezone-om relevantnim za tvoj projekat.
    private const string IanaTimeZoneId = "Europe/Sarajevo";
    private const string WindowsTimeZoneId = "Central European Standard Time";
    private static readonly TimeZoneInfo _localTimeZone = ResolveLocalTimeZone();

    // ── Public Properties ───────────────────────────────────────────
    public static TimeZoneInfo LocalTimeZone => _localTimeZone;
    public static DateTime UtcNow => DateTime.UtcNow;
    public static DateTime UtcToday => DateTime.UtcNow.Date;
    public static DateTime LocalNow => TimeZoneInfo.ConvertTimeFromUtc(UtcNow, _localTimeZone);
    public static DateTime LocalToday => LocalNow.Date;

    // ── Conversion Methods ──────────────────────────────────────────

    /// <summary>
    /// Converts any DateTime to UTC. Handles all DateTimeKind values safely.
    /// Unspecified Kind is treated as local timezone (configured above).
    /// </summary>
    public static DateTime ToUtc(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(value, DateTimeKind.Unspecified),
                _localTimeZone)
        };
    }

    /// <summary>
    /// Converts any DateTime to local timezone (configured above).
    /// UTC values are converted; Unspecified values are assumed already local.
    /// </summary>
    public static DateTime ToLocal(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => TimeZoneInfo.ConvertTimeFromUtc(value, _localTimeZone),
            DateTimeKind.Local => TimeZoneInfo.ConvertTime(value, _localTimeZone),
            _ => value
        };
    }

    /// <summary>
    /// Strips time component and returns date-only as UTC midnight.
    /// Useful for date comparisons and filters.
    /// </summary>
    public static DateTime ToUtcDate(DateTime value)
    {
        return new DateTime(value.Year, value.Month, value.Day, 0, 0, 0, DateTimeKind.Utc);
    }

    // ── Private ─────────────────────────────────────────────────────
    private static TimeZoneInfo ResolveLocalTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(IanaTimeZoneId);
        }
        catch (TimeZoneNotFoundException)
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById(WindowsTimeZoneId);
            }
            catch
            {
                return TimeZoneInfo.Utc;
            }
        }
        catch (InvalidTimeZoneException)
        {
            return TimeZoneInfo.Utc;
        }
    }
}
```

### Pravila za korištenje

| Kontekst | Koristi | NIKAD |
|---|---|---|
| Audit polja (CreatedAt, UpdatedAt) | `DateTimeUtils.UtcNow` | `DateTime.Now`, `DateTime.UtcNow` |
| Business logika (istek, rok) | `DateTimeUtils.UtcNow` | Direktni DateTime pozivi |
| Prikaz korisniku (backend report) | `DateTimeUtils.ToLocal(entity.CreatedAt)` | `.ToLocalTime()` |
| Parsiranje korisnikovog inputa | `DateTimeUtils.ToUtc(parsedDate)` | Pretpostavka o Kind-u |
| Date-only filter (od-do) | `DateTimeUtils.ToUtcDate(filterDate)` | Usporedba sa time komponentom |
| Seed data | `DateTimeUtils.UtcNow.AddDays(-3)` | `new DateTime(2025, 2, 10)` |
| DbContext SaveChanges override | `DateTimeUtils.UtcNow` | `DateTime.UtcNow` direktno |

### Frontend — UTC ↔ Local

```dart
// Parsing iz API-ja — uvijek UTC, convert to local za display
DateTime.parse(json['createdAt']).toLocal();

// Slanje na API — uvijek UTC
request.scheduledFor?.toUtc().toIso8601String();

// Display — DateFormatter radi sa local time (već converted)
DateFormatter.format(entity.createdAt);
```

**Pravilo:** Backend čuva UTC. Frontend prikazuje local. Konverzija u fromJson/toJson, nikad u UI kodu.

---

## 🪝 Service Hook Pattern — Validate / Prepare / After

> Hookovi su definirani u `BaseService` (vidjeti **Backend Foundation Classes**). Ovdje su pravila korištenja i primjeri.

### Odgovornosti Hookova

| Hook | Kad | Smije baciti? | Primjer |
|---|---|---|---|
| **Validate** | Provjere, business rules | ✅ Da — exception | Duplikat imena, FK ne postoji, zavisnosti |
| **Prepare** | Set defaults, generate, calculate | ❌ Ne | Generiši code, set status, izračunaj total |
| **After** | Side effects | ❌ Ne — failure NE rollback-uje | Log, cache invalidation, notifikacija |

**Execution redoslijed u BaseService:** `Adapt → Validate → Prepare → Repository → After → Return`

### Primjer — OrderService (složen, sva 3 hooka)

```csharp
protected override async Task ValidateCreateAsync(Order entity, CreateOrderRequest dto)
{
    var userExists = await _userRepo.AsQueryable().AnyAsync(u => u.Id == dto.UserId);
    if (!userExists) throw new KeyNotFoundException("Korisnik ne postoji.");
    if (dto.Items.Count == 0) throw new InvalidOperationException("Narudžba mora imati stavke.");
}

protected override async Task PrepareCreateAsync(Order entity, CreateOrderRequest dto)
{
    entity.Code = CodeGenerator.Generate("ORD");
    entity.Status = OrderStatus.Pending;
    entity.TotalAmount = await CalculateTotal(dto.Items);
}

protected override async Task AfterCreateAsync(Order entity, CreateOrderRequest dto)
{
    _logger.LogInformation("Order {Code} created for user {UserId}", entity.Code, entity.UserId);
}
```

### Primjer — CategoryService (jednostavan CRUD)

```csharp
protected override async Task ValidateCreateAsync(Category entity, CreateCategoryRequest dto)
{
    var exists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
    if (exists) throw new ConflictException("Kategorija sa ovim imenom već postoji.");
}

protected override async Task ValidateUpdateAsync(Category entity, UpdateCategoryRequest dto)
{
    if (!string.IsNullOrEmpty(dto.Name))
    {
        var exists = await _repository.AsQueryable()
            .AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && x.Id != entity.Id);
        if (exists) throw new ConflictException("Kategorija sa ovim imenom već postoji.");
    }
}

protected override async Task ValidateDeleteAsync(Category entity)
{
    var hasDependents = await _repository.AsQueryable()
        .Where(x => x.Id == entity.Id).SelectMany(x => x.Products).AnyAsync();
    if (hasDependents) throw new EntityHasDependentsException("kategoriju", "proizvode");
}
```

### ApplyFilter — ostaje u servisu

```csharp
protected override IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TFilter filter)
{
    query = query.Include(x => x.Related);
    query = query.WhereIf(!string.IsNullOrEmpty(filter.Search),
        x => x.Name.ToLower().Contains(filter.Search!.ToLower()));
    // ⚠️ force-unwrap siguran jer WhereIf evaluira predicate SAMO kad condition == true
    return filter.OrderBy?.ToLower() switch
    {
        "name" => query.OrderBy(x => x.Name),
        _ => query.OrderByDescending(x => x.CreatedAt)
    };
}
```

---

## 📄 Lookup Endpointi — Dropdown Pattern

> `BaseController` već ima `[HttpGet("lookup")]` endpoint, `BaseService` ima `GetLookupAsync()`. Ovdje je kako override-ovati za specifičan entitet i kako koristiti na frontendu.

### Backend — Override u Servisu

```csharp
// Application/Common/LookupResponse.cs — REUSABLE za sve lookup-e
public class LookupResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

// BaseService.GetLookupAsync() vraća samo Id — override da dodaš Name:
public override async Task<List<LookupResponse>> GetLookupAsync()
    => await _repository.AsQueryable()
        .OrderBy(x => x.Name)
        .Select(x => new LookupResponse { Id = x.Id, Name = x.Name })
        .ToListAsync();
```

### Frontend

```dart
// core/models/common/lookup_response.dart
class LookupResponse {
  final int id;
  final String name;
  factory LookupResponse.fromJson(Map<String, dynamic> json) => LookupResponse(
    id: (json['id'] ?? 0) as int, name: (json['name'] ?? '') as String);
}

// Provider
final categoryLookupProvider = FutureProvider.autoDispose<List<LookupResponse>>((ref) {
  return ref.watch(categoryServiceProvider).getLookup();
});

// U formi
ref.watch(categoryLookupProvider).when(
  data: (items) => DropdownButtonFormField<int>(
    items: items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Greška pri učitavanju'),
);
```

---

## 📤 File Upload

### Backend Konfiguracija

```csharp
"FileUpload": {
  "MaxFileSizeBytes": 5242880,       // 5 MB
  "AllowedImageExtensions": [".jpg", ".jpeg", ".png", ".webp"],
  "AllowedDocumentExtensions": [".pdf", ".doc", ".docx"],
  "StoragePath": "wwwroot/uploads"
}
```

### Backend Pravila

- Max file size konfigurisano, ne hardkodirano
- MIME type validacija — magic bytes, ne samo ekstenzija
- Safe filename — `FileHelper.GetSafeFileName()` sa GUID prefix
- Storage: lokalni disk dev, cloud produkcija
- Thumbnail za slike (max 300px)
- Soft delete NE briše fajl — periodičan cleanup

### Frontend Image Upload Flow

- **Package:** `image_picker` mobile, `file_picker` desktop
- **Compress before upload:** maxWidth 1200px, quality 85%
- **Desktop:** `file_picker` sa `allowedExtensions` matching backend config
- **Validate on pick:** check file size BEFORE upload
- **4 stanja:** uploading → new preview → existing image → placeholder
- Remove button, error builder na network images
- Multipart upload kroz `CrudServiceWithImage`

---

## 📦 Bulk Operations Pattern

### Kada koristiti

Admin dashboard multi-select akcije: bulk delete, bulk status change, bulk assign.

### Backend

```csharp
public class BulkDeleteRequest
{
    [Required]
    [MinLength(1, ErrorMessage = "Morate odabrati barem jednu stavku.")]
    public List<int> Ids { get; set; } = new();
}

public class BulkOperationResult
{
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public List<string> Errors { get; set; } = new();
}

// Controller
[HttpPost("bulk-delete")]
[Authorize(Roles = "Admin")]
public async Task<ActionResult<BulkOperationResult>> BulkDelete([FromBody] BulkDeleteRequest request)
    => Ok(await _service.BulkDeleteAsync(request.Ids));
```

### Frontend

- Checkbox kolona u tabeli, "Select All" header
- Bulk action bar kad 1+ selektovano
- Confirmation sa brojem: "Da li ste sigurni da želite obrisati 5 stavki?"
- Result feedback: "Uspješno obrisano 4 od 5."

---

## 🔌 Riverpod — Notifier/AsyncNotifier Pattern

### Provider Rules

1. **Jedan provider koncept po fajlu.**
2. **Uvijek `autoDispose`** osim ako state mora preživjeti navigaciju.
3. **Nikad UI logika u providerima.**
4. **`ref.watch()` u `build()`**, **`ref.read()` u callbackovima.**
5. **Provideri koriste core servise** — nikad direktno ApiClient.

### Desktop — Notifier za CRUD Liste

```dart
@riverpod
class {Entity}List extends _${Entity}List {
  @override
  ListState<{Entity}Response, {Entity}QueryFilter> build() {
    return ListState(filter: {Entity}QueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await ref.read({entity}ServiceProvider).getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> create(Create{Entity}Request request) async {
    await ref.read({entity}ServiceProvider).create(request);
    await load();
  }

  Future<void> update(int id, Update{Entity}Request request) async {
    await ref.read({entity}ServiceProvider).update(id, request);
    await load();
  }

  Future<void> delete(int id) async {
    await ref.read({entity}ServiceProvider).delete(id);
    await load();
  }

  void setSearch(String search) { /* update filter, load() */ }
  void setOrderBy(String orderBy) { /* update filter, load() */ }
  void goToPage(int page) { /* update filter, load() */ }
}
```

### Mutation Flow (Desktop)

> Feedback koristi **Unified AppSnackbars** sistem (vidjeti `CLAUDE-UI.md` sekciju 4). Poruke MORAJU biti opisne.

```dart
Future<void> _createOrder(CreateOrderRequest request) async {
  try {
    await ref.read(orderListProvider.notifier).create(request);
    if (mounted) {
      Navigator.pop(context);
      AppSnackbars.success(context, 'Narudžba uspješno kreirana.');  // OPISNO, ne "Uspjeh"
    }
  } on ApiException catch (e) {
    if (mounted) AppSnackbars.error(context, e.message);  // Poruka SA BACKENDA
  }
}
```

---

## 🌱 Environment & Configuration

### Backend — appsettings

```
appsettings.json                 # Shared non-secret: logging, pagination, FileUpload
appsettings.Development.json     # Dev DB, JWT secret — IN .gitignore
appsettings.Production.json      # Overridden by env vars — IN .gitignore
```

- **NIKAD secreti u appsettings.json**
- **User Secrets za lokalni dev**
- Produkcija: environment variables override

### Flutter — Environment Config

```dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'https://localhost:7xxx');
}
```

**NIKAD hardkodirani URL-ovi.**

---

## 🧹 Clean Program.cs — Extension Method Pattern

**`Program.cs` MORA biti čist i čitljiv na prvi pogled.** Sva konfiguracija ide u extension metode u `API/Extensions/`.

### Program.cs — Cilj

```csharp
using Reignition.API.Extensions;
using Reignition.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services (fluent chain)
builder.Services
    .AddInfrastructure(builder.Environment)
    .AddJwtAuthentication()
    .AddSwaggerWithAuth()
    .AddControllers();

var app = builder.Build();

// Seed database
await app.SeedDatabaseAsync();

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ExceptionHandlerMiddleware>();
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

**To je sve.** Nijedan `AddDbContext`, `AddScoped`, JWT konfiguracija, ili Swagger setup ne smije biti u `Program.cs`.

### ServiceCollectionExtensions.cs — `API/Extensions/`

Svaka logička grupa konfiguracije je zasebna extension metoda:

```csharp
public static class ServiceCollectionExtensions
{
    // Sva infrastruktura: DbContext, Mapster, Repositories, Services, Background services
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IWebHostEnvironment env)
    {
        // Database
        services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));

        // Mapster
        services.AddMapster();
        MappingConfig.Configure();

        // Repositories
        services.AddScoped(typeof(IRepository<,>), typeof(BaseRepository<,>));

        // Services — jedan AddScoped po servisu
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IOrderService, OrderService>();
        // ... ostali servisi

        // File storage
        services.AddScoped<IFileStorageService>(sp =>
            new FileStorageService(env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot")));

        // Background services (ako ih ima)
        services.AddHostedService<MembershipExpiryNotificationService>();

        return services;
    }

    // JWT auth konfiguracija — izolovana
    public static IServiceCollection AddJwtAuthentication(this IServiceCollection services)
    {
        var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
            ?? throw new InvalidOperationException("JWT_SECRET nije konfigurisan");
        // ... JWT setup
        return services;
    }

    // Swagger sa Bearer auth
    public static IServiceCollection AddSwaggerWithAuth(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c => { /* Bearer security definition */ });
        return services;
    }

    // Seed kao extension na WebApplication
    public static async Task SeedDatabaseAsync(this WebApplication app)
    {
        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await SeedService.SeedAsync(context);
    }
}
```

### Pravila

- **Fluent chain** — svaka metoda vraća `IServiceCollection` za chainanje: `.AddInfrastructure().AddJwtAuthentication().AddSwaggerWithAuth()`
- **Jedna odgovornost po metodi** — `AddInfrastructure` ne konfiguriše JWT, `AddJwtAuthentication` ne registruje servise
- **Secreti iz environment varijabli** — nikad iz `appsettings.json`, baciti `InvalidOperationException` ako nedostaje
- **Seed sa retry logikom** za produkciju (DB možda nije odmah dostupan u Docker-u):

```csharp
public static async Task SeedDatabaseAsync(this WebApplication app)
{
    const int maxRetries = 5;
    const int delaySeconds = 5;

    for (var attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            using var scope = app.Services.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            await SeedService.SeedAsync(context);
            return;
        }
        catch (Exception ex)
        {
            if (attempt < maxRetries)
                await Task.Delay(TimeSpan.FromSeconds(delaySeconds));
            else
                Console.WriteLine("All seed attempts failed. Starting without seed data.");
        }
    }
}
```

---

## 📄 Pagination

### Backend

```csharp
public class PagedResult<T> { public List<T> Items; public int TotalCount; public int PageNumber; public int PageSize; }
public class PaginationRequest { public int PageNumber { get; set; } = 1; public int PageSize { get; set; } = 10; }
```

### Frontend — MORA odgovarati backendu

```dart
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
}
```

Defaults: Desktop `pageSize = 10`, Mobile `pageSize = 20`.

---

## 🗃️ Migration Workflow

```bash
dotnet ef migrations add {DescriptiveName} --project Reignition.Infrastructure --startup-project Reignition.API
dotnet ef database update --project Reignition.Infrastructure --startup-project Reignition.API
dotnet ef database update {PreviousMigrationName}  # rollback
dotnet ef migrations remove                         # remove last unapplied
```

- Jedna migracija po logičkoj promjeni — `AddPhoneToUser`, NE `Migration1`
- NIKAD mijenjaj primijenjenu migraciju
- Provjeri generated SQL: `dotnet ef migrations script`
- **⚠️ PITAJ korisnika prije kreiranja migracije**

---

## 🌱 Seed Data

- **`HasData()` SAMO za statične lookup tablice** (roles, statuses) sa hardkodiranim ID-ovima — evaluira u migration-time
- **`SeedService` za dinamične podatke** (orders, users, samples) — poziva se na app startup, koristi `DateTimeUtils.UtcNow`
- **NIKAD statični datumi** u SeedService — uvijek relativno na `DateTimeUtils.UtcNow`
- Seed MORA poštovati ista pravila kao servisi
- **PITAJ korisnika** koje podatke treba seedovati

```csharp
// ✅ HasData za lookup
builder.Entity<Role>().HasData(
    new Role { Id = 1, Name = "Admin", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
);

// ✅ SeedService za dinamične — poziva se iz Program.cs
public async Task SeedAsync(IServiceProvider services)
{
    var context = services.GetRequiredService<AppDbContext>();
    if (await context.Orders.AnyAsync()) return;

    var now = DateTimeUtils.UtcNow;
    context.Orders.AddRange(
        new Order { Code = "ORD-SEED01", CreatedAt = now.AddDays(-3), Status = OrderStatus.Completed },
        new Order { Code = "ORD-SEED02", ScheduledFor = now.AddDays(7), Status = OrderStatus.Confirmed }
    );
    await context.SaveChangesAsync();
}
```

---

## ❌ Error Handling — Full Flow

> Middleware i custom exception-i su definirani u **Backend Foundation Classes**. Ovdje je kompletni flow od servisa do UI-a.

```
Service baca exception (bosanska poruka)
  → ExceptionHandlerMiddleware hvata
  → Mapira:  KeyNotFound→404 · Conflict→409 · EntityHasDependents→409
             Forbidden→403 · Unauthorized→401 · InvalidOp→400 · Argument→400
             NotSupported→501 · _→500 (generička poruka, NIKAD stack trace)
  → Vraća:   { "error": "Poruka", "statusCode": 409 }
  → ApiClient parsira → ApiException.fromResponse(statusCode, body)
  → Provider hvata → state.error = e.message
  → Widget prikazuje → snackbar / retry dugme
```

### Frontend — ApiException

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isForbidden => statusCode == 403;
  bool get isUnauthorized => statusCode == 401;
  bool get isBadRequest => statusCode == 400;

  factory ApiException.fromResponse(int statusCode, String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(
        statusCode: statusCode,
        message: json['error'] ?? json['message'] ?? 'Greška: $statusCode',
      );
    } catch (_) {
      return ApiException(statusCode: statusCode, message: 'Greška: $statusCode');
    }
  }
}
```

---

## 🔐 Auth Flow

- **Backend:** JWT sa Claims (NameIdentifier, Name, Email, Role). `[Authorize(Roles = "Admin")]`.
- **Frontend:** `TokenStorage` (FlutterSecureStorage). `ApiClient` auto-attach `Bearer` token.
- **401 Intercept:** ApiClient → `TokenStorage.clear()` → login → "Sesija je istekla."
- `CreatedBy`/`UpdatedBy` automatski iz `HttpContext.User`.

---

## 🌿 Git Workflow — GitHub Flow

### Branching

```
main                    # Uvijek deployable, zaštićen
├── feature/{name}      # feature/add-order-screen
├── fix/{name}          # fix/membership-status-edge-case
└── refactor/{name}     # refactor/extract-payment-service
```

### Commit Poruke

**Format:** `scope: kratki opis promjene`

**Scope — OBAVEZAN, označava sloj:**

| Scope | Kad | Primjer |
|---|---|---|
| `backend` | Entity, DTO, service, controller, migration, config | `backend: add order entity and service` |
| `core` | Flutter shared package — modeli, servisi, helperi | `core: add order models and query filter` |
| `desktop` | Desktop app — provideri, screeni, widgeti | `desktop: add order list screen with filters` |
| `mobile` | Mobile app — provideri, screeni, widgeti | `mobile: add order card and detail screen` |
| `fix/scope` | Bug fix u specifičnom sloju | `fix/backend: handle duplicate category name` |
| `refactor/scope` | Refaktor u specifičnom sloju | `refactor/core: extract base query filter` |
| `config` | CI/CD, Docker, .gitignore, appsettings struktura | `config: add docker-compose for dev` |

**Pravila:**

- **Engleski, lowercase, bez tačke na kraju**
- **Jedan commit = jedna logička promjena u jednom sloju** — NE "add order feature" sa 30 fajlova iz 3 sloja. Commit po fazi: backend commit → core commit → desktop commit.
- **Kratak opis (max ~72 karaktera)** — šta je urađeno, ne zašto ili kako
- **Bez emojija, Co-authored-by, AI markera** — commit ne smije odavati da je AI pisao kod
- **Destructive git actions (force push, rebase main, delete branch) — PITAJ prije**

### ✅ Dobri Commitovi

```
backend: add repair-request entity and service
backend: add migration CreateRepairRequest
core: add repair request models and service
desktop: add repair request list screen
desktop: add repair request form dialog
fix/backend: return 409 on duplicate category name
fix/desktop: debounce search on order list
refactor/core: move date formatting to DateFormatter helper
config: add production appsettings template
```

### ❌ Loši Commitovi

```
added stuff                          # neopisno
Add Order Feature                    # nije lowercase, preširoko (koji sloj?)
backend: Add order entity.           # uppercase A, tačka na kraju
fix bug                              # nema scope, neopisno
🎉 feat: add order screen            # emoji, nepotreban feat prefix
update files                         # šta? gdje? zašto?
WIP                                  # nikad commitaj WIP
backend + core + desktop: add order  # NIKAD multi-scope — razdvoji na 3 commita
```

---

## 🧪 Testing · 📒 Logging

- **Backend:** Service testovi za hookove i ApplyFilter. `ILogger<T>`, structured `{Placeholder}`.
- **Flutter:** Widget testovi za forme. Unit za helpere. `developer.log()`, nikad `print()`.
- **NIKAD logirati:** lozinke, tokene, lične podatke.

---

## 🛠️ Shared Helpers

### Core Validators (`core/validators/FormValidators`)

`required`, `length`, `email`, `range`, `phone`, `password`, `confirmPassword`, `compose` — poruke bosanski.

### Core Helpers (`core/helpers/`)

DateFormatter, CurrencyFormatter, StringExtensions, NullableStringExtensions, EnumHelper, FileHelper, PaginationHelper.

### Backend Helpers (`Application/Helpers/`)

SlugGenerator, CodeGenerator, `WhereIf` extension.

---

## 🚫 Anti-Patterns

### Flutter

| Anti-Pattern | Rješenje |
|---|---|
| `setState()` shared state | Riverpod |
| Business logika u widgetima | Provideri |
| `ref.watch()` u callbackovima | `ref.read()` |
| God widget 300+ linija | Ekstrahuj sub-widgete |
| Hardkodirane boje | `Theme.of(context)` |
| Lista bez empty state | 4 stanja |
| Search bez debounce | 400ms Timer |
| Delete bez potvrde | AlertDialog |
| Silent mutacija | Snackbar |
| Context async bez `mounted` | Provjeri `mounted` |
| `Expanded` u scroll view | Fixed heights |
| Gradient dugmad | Flat, 0 elevation |

### .NET

| Anti-Pattern | Rješenje |
|---|---|
| Logika u Controlleru | Service hookovi |
| Logika u Repositoriju | Repository = data access |
| Isti DTO request/response | Separate |
| AutoMapper | Mapster |
| `DateTime.Now` | `DateTimeUtils.UtcNow` |
| Fizičko brisanje | Soft delete |

---

## ⚠️ Known Gotchas

| Problem | Rješenje |
|---|---|
| `List<dynamic>` crash | `?? <Type>[]` |
| RenderFlex overflow | `Flexible` + `TextOverflow.ellipsis` |
| Keyboard pokriva forme | `SingleChildScrollView` + `viewInsets.bottom` |
| Snackbari se gomilaju | `hideCurrentSnackBar()` first |
| Lista se ne update | Provider `load()` nakon mutacije |
| Seed u HasData dinamičke datume | Koristi SeedService umjesto HasData |
| WhereIf NullReference | Condition mora provjeriti null PRIJE force-unwrap |
| DateTimeKind.Unspecified | `DateTimeUtils.ToUtc()` za sigurnu konverziju |

---

## 📋 Pre-Commit Checklist

### Flutter

- [ ] Limiti poštovani, early return, `ref.watch/read` pravilno
- [ ] Theme boje, AppSpacing, 4 stanja, debounce, delete potvrda, snackbar
- [ ] Forme: pre-populate, dispose, `mounted`, backend-matching validators
- [ ] Zero overflow, SafeArea mobile, responsive
- [ ] **Contract Sync** ✓ · **CLAUDE-UI.md** pravila ✓

### .NET

- [ ] Controller thin, service hooks, separate DTOs, Mapster
- [ ] `DateTimeUtils.UtcNow`, soft delete, API URL conventions
- [ ] Lookup endpoint, structured logging, early return

---

## 🔒 Requires Approval

**PITAJ:** Backend/DB/auth, novi entiteti, migracije, Docker, security, bulk ops, API rute, major refaktori.

**Slobodno:** Minor UI, bug fix bez contract promjene, validatori/helperi.

---

## ⛔ NE DIRATI DOK NIJE SPREMNO

- **Messaging & Worker** — RabbitMQ/MassTransit. Sinhrono ili TODO + pitaj.
- **Real-Time (SignalR)** — Polling ili TODO + pitaj.
- **Docker** — tek kad je app funkcionalna. PITAJ za setup detalje.

---

## 🚫 Forbidden

Hardcoding · AI komentari · Security promjene bez dozvole · RenderFlex overflow · Destruktivne git akcije · `print()`/`Console.WriteLine()` · `DateTime.Now` direktno · Gradient/glow UI · Statički seed datumi

---

## 💬 Communication Protocol

1. Navedi fajlove prije pisanja, grupisano po sloju
2. Kreiraj jedan po jedan, dependency order
3. **Nikad ne dump-aj sav kod odjednom**

### 🛑 Checkpoint: Nakon logičke cjeline → izvijesti → pročitaj rules → pitaj potvrdu

### 🙋 Always Ask — Never Guess

**Nikad ne donesi arhitektonsku odluku sam.** Bolje 5 pitanja nego 5 fajlova za refaktor.

---

## 🔧 Naming Conventions

### Flutter

| Tip | Konvencija | Primjer |
|---|---|---|
| Fajlovi | snake_case | `order_card.dart` |
| Klase | PascalCase | `OrderCard` |
| Screens | + Screen | `OrderScreen` |
| Providers | camelCase + Provider | `orderListProvider` |

### .NET

| Tip | Konvencija | Primjer |
|---|---|---|
| Klase | PascalCase | `OrderService` |
| Interfejsi | I + PascalCase | `IOrderService` |
| Create DTO | `Create{Entity}Request` | `CreateOrderRequest` |
| Update DTO | `Update{Entity}Request` | `UpdateOrderRequest` |
| Response | `{Entity}Response` | `OrderResponse` |
| Filter | `{Entity}QueryFilter` | `OrderQueryFilter` |
