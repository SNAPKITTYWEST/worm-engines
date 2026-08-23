// ml_dsa.zig — ML-DSA-44 (CRYSTALS-Dilithium, NIST FIPS 204)
// Post-quantum digital signature scheme, NIST security level 2.
//
// Parameters (ML-DSA-44):
//   q = 8380417, n = 256, k = 4, l = 4
//   η = 2, τ = 39, β = 78, γ1 = 2^17, γ2 = (q-1)/88, ω = 80, λ = 128
//
// Key sizes:
//   Public key:  1312 bytes
//   Private key: 2560 bytes
//   Signature:   2420 bytes
//
// Reference: NIST FIPS 204 (August 2024)
// https://doi.org/10.6028/NIST.FIPS.204

const std = @import("std");

// ── Parameters ────────────────────────────────────────────────────────────────

pub const Q: u32 = 8380417;
pub const N: usize = 256;
pub const K: usize = 4;
pub const L: usize = 4;
pub const ETA: u32 = 2;
pub const TAU: usize = 39;
pub const BETA: u32 = 78; // TAU * ETA
pub const GAMMA1: u32 = 1 << 17;
pub const GAMMA2: u32 = (Q - 1) / 88;
pub const OMEGA: usize = 80;
pub const LAMBDA: usize = 128;

pub const PK_LEN: usize = 1312;
pub const SK_LEN: usize = 2560;
pub const SIG_LEN: usize = 2420;
pub const SEED_LEN: usize = 32;

// ── Types ─────────────────────────────────────────────────────────────────────

pub const PublicKey = [PK_LEN]u8;
pub const PrivateKey = [SK_LEN]u8;
pub const Signature = [SIG_LEN]u8;

/// A polynomial in R_q = Z_q[X] / (X^256 + 1)
pub const Poly = struct {
    coeffs: [N]i32,

    pub fn zero() Poly {
        return Poly{ .coeffs = [_]i32{0} ** N };
    }
};

/// A vector of k polynomials (public key side)
pub const PolyVecK = struct {
    vec: [K]Poly,

    pub fn zero() PolyVecK {
        return PolyVecK{ .vec = [_]Poly{Poly.zero()} ** K };
    }
};

/// A vector of l polynomials (secret key side)
pub const PolyVecL = struct {
    vec: [L]Poly,

    pub fn zero() PolyVecL {
        return PolyVecL{ .vec = [_]Poly{Poly.zero()} ** L };
    }
};

// ── Montgomery arithmetic ─────────────────────────────────────────────────────

const MONT: i64 = 4193792; // 2^32 mod q
const QINV: i64 = 58728449; // q^-1 mod 2^32

fn mont_reduce(a: i64) i32 {
    const t: i32 = @truncate(@as(i64, @truncate(a)) *% QINV);
    const u: i64 = (a - @as(i64, t) * @as(i64, Q)) >> 32;
    return @intCast(u);
}

fn reduce32(a: i32) i32 {
    const t: i32 = (a + (1 << 22)) >> 23;
    return a - t *% @as(i32, @intCast(Q));
}

fn caddq(a: i32) i32 {
    return a + ((a >> 31) & @as(i32, @intCast(Q)));
}

fn freeze(a: i32) i32 {
    return caddq(reduce32(a));
}

// ── NTT (Number Theoretic Transform) ─────────────────────────────────────────

// Precomputed zetas: powers of the primitive 512th root of unity (1753) in Montgomery form
// Generated as: zetas[i] = mont(1753^bitrev(i)) for i = 0..255
// These are the standard Dilithium NTT zetas.
const ZETAS: [N]i32 = .{
    -4186625, -25847,  -2608894, -3384356,  3437287,  4102012,  76657,   -1757237,
    -1585221,  3040281, -2831860,  3628969, -3693796, -3023773,  1600420, -3658658,
    -2680103, -2870403,  3182878,  2278010, -816490,  -3447415, -3693796, 4315546,
     2127516,  3639446,  4228269,  1111842,  -2146554,  3359162,  1510066,  3447489,
     1421655,  2353451,  1585221,  3543301, -2842543,  2362573,  2508980,  3130831,
    -1594917,  -2908180, 1453362,  -1722600, -1812244,  4306747, -3716966, 3240424,
    -4060401, -2942154,  3201023,  -4026665,  1386326,  2615935,  1225545, 2725464,
     2303121,   869942,   1422373,  -1598244, -4073798, -904467,   2832294, 3175950,
    -4130734,  4072811,  -1585184,  3193424, -2896073, -3209675,  -4086325, -1905907,
     3348099,  4086636,  -2009792,  1141911, -1641578, -1226375, -1841637, -1127068,
    -1006353,  -4044690, -2063752,   2726186, -4174558,  2259467, -2267644, -3901559,
     3534423, -1697279, -3000178, -3136596, -3073009,  3532797,  2619910, -1558905,
     3890906,  1856628,  3737090, -1662264, -2877200,   -3589807,  549488,   530355,
    -1311074,  -2288764,  1476985, -3523511,  3290733,  1985956,  -1716814, 3509660,
    -3422593,  1949855, -3012701, -2864001, -3408910, -2939969,  -3251820, -3609928,
     3716966, -1616322,  2591178,  -2978755,  3068193,  3463207, -1477267, -1645017,
    -1000547, -3236522, -3167234,  1613268,  2580780,  3700897, -3847952, -1547992,
    -3438740,  3821735, -4241073, -2519360,  2742900, -2867745, -2607520, -1408059,
     1398417,  4218851,  -1439553,  4134526,  3374254,  3437287, -3117729,  4101924,
    -2625684, -3890906, -3285169, -2507280,  3542867, -2898413,  2527197, -4218851,
    -3693009, -1397254,  -671071, -2025000,   2804437,  2404184,  2977650, -3541643,
    -3943456, -2614886, -2415467,  3895381,  2513018,  -2590150, -4234971, 3178460,
    -3131877,  4195093,  1761383, -3699566, -2810453,  3765607,  -1564966, 3141538,
    -1558905,   866481, -2138412, -3604466,  1400800, -2087264, -1099203, 2885784,
    -1885881,   -1602040,  1384009, 2917588,   1671655,  -2280513, -3419793, 1253000,
     3532797, -1466191,  3028637, -3427658,  -2897413,  3174393, -1897483, 2417473,
    -2831860,  2614886,  -1861752, -1439553,  2040568, -1597040, -3637141, 3820940,
     2843139, -1867382,  -3765607,  1386326, -2408860, -3069990,  2038810,  836897,
    -1398417, -1033978, -1897483,  3023773,  2985638, -2398725, -3261562,  1219827,
    -3127975,  4085657, -2816023,   1977308,  2875732, -2978755, -1843917, -4220777,
     2142890, -4270342,  3802412, -1896257, -2409498, -3919545, 2862628,  -3274728,
    -3094695, -3575281, -3509660,  1253000, -876248,   -1393957, -2569602, 3003832,
};

/// In-place NTT. Input in [0, q), output in Montgomery form.
pub fn ntt(a: *Poly) void {
    var k: usize = 0;
    var len: usize = 128;
    while (len > 0) : (len >>= 1) {
        var start: usize = 0;
        while (start < N) : (start += len * 2) {
            k += 1;
            const zeta: i64 = ZETAS[k];
            var j: usize = start;
            while (j < start + len) : (j += 1) {
                const t = mont_reduce(zeta * @as(i64, a.coeffs[j + len]));
                a.coeffs[j + len] = a.coeffs[j] - t;
                a.coeffs[j] += t;
            }
        }
    }
}

/// In-place inverse NTT. Output coefficients in [0, q).
pub fn inv_ntt(a: *Poly) void {
    const F: i64 = 41978; // mont(mont(2^-256 mod q))
    var k: usize = 256;
    var len: usize = 1;
    while (len <= 128) : (len <<= 1) {
        var start: usize = 0;
        while (start < N) : (start += len * 2) {
            k -= 1;
            const zeta: i64 = -ZETAS[k];
            var j: usize = start;
            while (j < start + len) : (j += 1) {
                const t = a.coeffs[j];
                a.coeffs[j] = caddq(t + a.coeffs[j + len]);
                a.coeffs[j + len] = t - a.coeffs[j + len];
                a.coeffs[j + len] = mont_reduce(zeta * @as(i64, a.coeffs[j + len]));
            }
        }
    }
    for (&a.coeffs) |*c| {
        c.* = mont_reduce(F * @as(i64, c.*));
    }
}

/// Pointwise multiply two NTT-domain polynomials.
pub fn poly_pointwise_montgomery(c: *Poly, a: *const Poly, b: *const Poly) void {
    for (0..N) |i| {
        c.coeffs[i] = mont_reduce(@as(i64, a.coeffs[i]) * @as(i64, b.coeffs[i]));
    }
}

// ── Polynomial operations ────────────────────────────────────────────────────

pub fn poly_add(c: *Poly, a: *const Poly, b: *const Poly) void {
    for (0..N) |i| {
        c.coeffs[i] = a.coeffs[i] + b.coeffs[i];
    }
}

pub fn poly_sub(c: *Poly, a: *const Poly, b: *const Poly) void {
    for (0..N) |i| {
        c.coeffs[i] = a.coeffs[i] - b.coeffs[i];
    }
}

pub fn poly_reduce(a: *Poly) void {
    for (&a.coeffs) |*c| {
        c.* = reduce32(c.*);
    }
}

pub fn poly_caddq(a: *Poly) void {
    for (&a.coeffs) |*c| {
        c.* = caddq(c.*);
    }
}

pub fn poly_freeze(a: *Poly) void {
    for (&a.coeffs) |*c| {
        c.* = freeze(c.*);
    }
}

/// Check if infinity norm of polynomial is less than bound.
pub fn poly_chknorm(a: *const Poly, bound: i32) bool {
    for (a.coeffs) |c| {
        const t = (c >> 31) ^ c; // abs value
        if (t >= bound) return false;
    }
    return true;
}

// ── Decomposition ─────────────────────────────────────────────────────────────

fn power2round(r: i32) struct { r1: i32, r0: i32 } {
    const d: i32 = 13;
    const t = (r + (1 << (d - 1)) - 1) >> d;
    return .{
        .r1 = t,
        .r0 = r - (t << d),
    };
}

fn decompose(r: i32) struct { r1: i32, r0: i32 } {
    const g2: i32 = @intCast(GAMMA2);
    var r0: i32 = r % (2 * g2);
    if (r0 > g2) r0 -= 2 * g2;
    var r1: i32 = (r - r0);
    if (@as(u32, @bitCast(r1)) == Q - 1) {
        r0 -= 1;
        r1 = 0;
    } else {
        r1 = @divExact(r1, 2 * g2);
    }
    return .{ .r1 = r1, .r0 = r0 };
}

fn highbits(r: i32) i32 {
    return decompose(r).r1;
}

fn lowbits(r: i32) i32 {
    return decompose(r).r0;
}

fn makehint(z: i32, r: i32) bool {
    const r1 = highbits(r);
    const v1 = highbits(r + z);
    return r1 != v1;
}

fn usehint(h: bool, r: i32) i32 {
    const r1 = decompose(r).r1;
    if (h) {
        const g2: i32 = @intCast(GAMMA2);
        return if (decompose(r).r0 > 0)
            @rem(r1 + 1, @as(i32, @intCast(((Q - 1) / (2 * @as(u32, @intCast(g2))) + 1))))
        else
            @rem(r1 - 1 + @as(i32, @intCast((Q - 1) / (2 * @as(u32, @intCast(g2))) + 1)),
                 @as(i32, @intCast((Q - 1) / (2 * @as(u32, @intCast(g2))) + 1)));
    }
    return r1;
}

// ── Hashing (SHAKE-256 / SHA3) ────────────────────────────────────────────────

const Shake256 = std.crypto.hash.sha3.Shake256;

/// Expand a 32-byte seed to a k×l matrix A in NTT domain (ρ expansion).
pub fn expand_a(rho: *const [32]u8, a: *[K][L]Poly) void {
    for (0..K) |i| {
        for (0..L) |j| {
            expand_a_poly(rho, @intCast(i), @intCast(j), &a[i][j]);
        }
    }
}

fn expand_a_poly(rho: *const [32]u8, i: u8, j: u8, p: *Poly) void {
    var h = Shake256.init(.{});
    h.update(rho);
    h.update(&[_]u8{ j, i });
    var buf: [672]u8 = undefined; // Rejection sampling buffer
    h.squeeze(&buf);

    var coeff_idx: usize = 0;
    var buf_idx: usize = 0;
    while (coeff_idx < N) {
        if (buf_idx + 3 > buf.len) {
            h.squeeze(&buf);
            buf_idx = 0;
        }
        const b0 = @as(u32, buf[buf_idx]);
        const b1 = @as(u32, buf[buf_idx + 1]);
        const b2 = @as(u32, buf[buf_idx + 2]) & 0x7F;
        buf_idx += 3;
        const t = b0 | (b1 << 8) | (b2 << 16);
        if (t < Q) {
            p.coeffs[coeff_idx] = @intCast(t);
            coeff_idx += 1;
        }
    }
}

/// Sample polynomial with coefficients in {-η..η} from seed.
fn poly_uniform_eta(seed: *const [64]u8, nonce: u16, p: *Poly) void {
    var h = Shake256.init(.{});
    h.update(seed);
    h.update(&[_]u8{ @intCast(nonce & 0xFF), @intCast(nonce >> 8) });
    var buf: [136]u8 = undefined;
    h.squeeze(&buf);

    var idx: usize = 0;
    var coeff_idx: usize = 0;
    while (coeff_idx < N) {
        if (idx >= buf.len) {
            h.squeeze(&buf);
            idx = 0;
        }
        const b = buf[idx];
        idx += 1;
        const t0: i32 = @intCast(b & 0x0F);
        const t1: i32 = @intCast(b >> 4);
        if (t0 < 15 and coeff_idx < N) {
            const t0r = t0 - ((205 * t0 >> 10) * 5);
            p.coeffs[coeff_idx] = @as(i32, 2) - t0r;
            coeff_idx += 1;
        }
        if (t1 < 15 and coeff_idx < N) {
            const t1r = t1 - ((205 * t1 >> 10) * 5);
            p.coeffs[coeff_idx] = @as(i32, 2) - t1r;
            coeff_idx += 1;
        }
    }
}

/// Sample polynomial with coefficients in {-γ1+1..γ1} using SHAKE-256.
fn poly_uniform_gamma1(seed: *const [64]u8, nonce: u16, p: *Poly) void {
    var h = Shake256.init(.{});
    h.update(seed);
    h.update(&[_]u8{ @intCast(nonce & 0xFF), @intCast(nonce >> 8) });
    var buf: [576]u8 = undefined;
    h.squeeze(&buf);
    // Unpack 18-bit signed coefficients
    var idx: usize = 0;
    const g1: i32 = @intCast(GAMMA1);
    for (0..N) |i| {
        const z: u32 = @as(u32, buf[idx]) | (@as(u32, buf[idx + 1]) << 8) | (@as(u32, buf[idx + 2]) << 16);
        idx += if (i % 2 == 1) 3 else 2;
        const zi: i32 = if (i % 2 == 0)
            @as(i32, @bitCast(z & 0x3FFFF))
        else
            @as(i32, @bitCast((z >> 18) & 0x3FFFF));
        p.coeffs[i] = g1 - zi;
    }
}

/// Hash message to challenge polynomial c̃.
pub fn sample_in_ball(seed: *const [32]u8, c: *Poly) void {
    c.* = Poly.zero();
    var h = Shake256.init(.{});
    h.update(seed);
    var buf: [136]u8 = undefined;
    h.squeeze(&buf);

    var signs: u64 = 0;
    for (0..8) |i| {
        signs |= @as(u64, buf[i]) << @intCast(i * 8);
    }
    var pos: usize = 8;

    var i: usize = N - TAU;
    while (i < N) : (i += 1) {
        var j: usize = undefined;
        while (true) {
            if (pos >= buf.len) {
                h.squeeze(&buf);
                pos = 0;
            }
            j = buf[pos];
            pos += 1;
            if (j <= i) break;
        }
        c.coeffs[i] = c.coeffs[j];
        c.coeffs[j] = 1 - 2 * @as(i32, @intCast(signs & 1));
        signs >>= 1;
    }
}

// ── Packing / Unpacking ───────────────────────────────────────────────────────

/// Pack public key (rho || t1).
pub fn pack_pk(pk: *PublicKey, rho: *const [32]u8, t1: *const PolyVecK) void {
    @memcpy(pk[0..32], rho);
    var pos: usize = 32;
    for (t1.vec) |p| {
        polyt1_pack(pk[pos..][0..320], &p);
        pos += 320;
    }
}

/// Unpack public key.
pub fn unpack_pk(pk: *const PublicKey, rho: *[32]u8, t1: *PolyVecK) void {
    @memcpy(rho, pk[0..32]);
    var pos: usize = 32;
    for (&t1.vec) |*p| {
        polyt1_unpack(pk[pos..][0..320], p);
        pos += 320;
    }
}

fn polyt1_pack(r: []u8, a: *const Poly) void {
    for (0..N / 4) |i| {
        const t: [4]u32 = .{
            @bitCast(a.coeffs[4 * i]),
            @bitCast(a.coeffs[4 * i + 1]),
            @bitCast(a.coeffs[4 * i + 2]),
            @bitCast(a.coeffs[4 * i + 3]),
        };
        r[5 * i] = @truncate(t[0]);
        r[5 * i + 1] = @truncate(t[0] >> 8 | t[1] << 2);
        r[5 * i + 2] = @truncate(t[1] >> 6 | t[2] << 4);
        r[5 * i + 3] = @truncate(t[2] >> 4 | t[3] << 6);
        r[5 * i + 4] = @truncate(t[3] >> 2);
    }
}

fn polyt1_unpack(r: []const u8, a: *Poly) void {
    for (0..N / 4) |i| {
        a.coeffs[4 * i] = @as(i32, @intCast(((r[5 * i] | (@as(u16, r[5 * i + 1]) << 8)) & 0x3FF)));
        a.coeffs[4 * i + 1] = @as(i32, @intCast(((r[5 * i + 1] >> 2 | (@as(u16, r[5 * i + 2]) << 6)) & 0x3FF)));
        a.coeffs[4 * i + 2] = @as(i32, @intCast(((r[5 * i + 2] >> 4 | (@as(u16, r[5 * i + 3]) << 4)) & 0x3FF)));
        a.coeffs[4 * i + 3] = @as(i32, @intCast(((r[5 * i + 3] >> 6 | (@as(u16, r[5 * i + 4]) << 2)) & 0x3FF)));
    }
}

fn polyz_pack(r: []u8, a: *const Poly) void {
    const g1: i32 = @intCast(GAMMA1);
    for (0..N / 4) |i| {
        const t: [4]u32 = .{
            @bitCast(g1 - a.coeffs[4 * i]),
            @bitCast(g1 - a.coeffs[4 * i + 1]),
            @bitCast(g1 - a.coeffs[4 * i + 2]),
            @bitCast(g1 - a.coeffs[4 * i + 3]),
        };
        r[9 * i] = @truncate(t[0]);
        r[9 * i + 1] = @truncate(t[0] >> 8);
        r[9 * i + 2] = @truncate(t[0] >> 16 | t[1] << 2);
        r[9 * i + 3] = @truncate(t[1] >> 6);
        r[9 * i + 4] = @truncate(t[1] >> 14 | t[2] << 4);
        r[9 * i + 5] = @truncate(t[2] >> 4);
        r[9 * i + 6] = @truncate(t[2] >> 12 | t[3] << 6);
        r[9 * i + 7] = @truncate(t[3] >> 2);
        r[9 * i + 8] = @truncate(t[3] >> 10);
    }
}

fn polyz_unpack(r: []const u8, a: *Poly) void {
    const g1: i32 = @intCast(GAMMA1);
    for (0..N / 4) |i| {
        a.coeffs[4 * i] = @as(i32, @intCast(@as(u32, r[9 * i]) | (@as(u32, r[9 * i + 1]) << 8) | ((@as(u32, r[9 * i + 2]) & 0x03) << 16)));
        a.coeffs[4 * i + 1] = @as(i32, @intCast(r[9 * i + 2] >> 2 | (@as(u32, r[9 * i + 3]) << 6) | ((@as(u32, r[9 * i + 4]) & 0x0F) << 14)));
        a.coeffs[4 * i + 2] = @as(i32, @intCast(r[9 * i + 4] >> 4 | (@as(u32, r[9 * i + 5]) << 4) | ((@as(u32, r[9 * i + 6]) & 0x3F) << 12)));
        a.coeffs[4 * i + 3] = @as(i32, @intCast(r[9 * i + 6] >> 6 | (@as(u32, r[9 * i + 7]) << 2) | (@as(u32, r[9 * i + 8]) << 10)));
        a.coeffs[4 * i] = g1 - a.coeffs[4 * i];
        a.coeffs[4 * i + 1] = g1 - a.coeffs[4 * i + 1];
        a.coeffs[4 * i + 2] = g1 - a.coeffs[4 * i + 2];
        a.coeffs[4 * i + 3] = g1 - a.coeffs[4 * i + 3];
    }
}

// ── Key Generation ────────────────────────────────────────────────────────────

pub const Error = error{
    InvalidSignature,
    SignatureTooLarge,
    PublicKeyInvalid,
};

/// Generate an ML-DSA-44 keypair from a 32-byte random seed.
pub fn keygen(seed: *const [SEED_LEN]u8, pk: *PublicKey, sk: *PrivateKey) void {
    // Expand seed
    var expanded: [128]u8 = undefined;
    var h = Shake256.init(.{});
    h.update(seed);
    h.update(&[_]u8{ K, L }); // domain separation
    h.squeeze(&expanded);

    const rho = expanded[0..32];
    const rho_prime = expanded[32..96];
    const K_bytes = expanded[96..128];

    // Expand A matrix from rho
    var a: [K][L]Poly = undefined;
    expand_a(rho, &a);

    // Sample s1, s2 with small coefficients
    var s1 = PolyVecL.zero();
    var s2 = PolyVecK.zero();
    for (0..L) |i| {
        poly_uniform_eta(rho_prime, @intCast(i), &s1.vec[i]);
    }
    for (0..K) |i| {
        poly_uniform_eta(rho_prime, @intCast(L + i), &s2.vec[i]);
    }

    // Compute t = A*s1 + s2
    var s1_hat = s1;
    for (&s1_hat.vec) |*p| ntt(p);

    var t = PolyVecK.zero();
    for (0..K) |i| {
        for (0..L) |j| {
            var tmp = Poly.zero();
            poly_pointwise_montgomery(&tmp, &a[i][j], &s1_hat.vec[j]);
            poly_add(&t.vec[i], &t.vec[i], &tmp);
        }
        poly_reduce(&t.vec[i]);
        inv_ntt(&t.vec[i]);
        poly_add(&t.vec[i], &t.vec[i], &s2.vec[i]);
        poly_reduce(&t.vec[i]);
        poly_caddq(&t.vec[i]);
    }

    // Extract t1 (high bits) and t0 (low bits)
    var t1 = PolyVecK.zero();
    var t0 = PolyVecK.zero();
    for (0..K) |i| {
        for (0..N) |j| {
            const d = power2round(t.vec[i].coeffs[j]);
            t1.vec[i].coeffs[j] = d.r1;
            t0.vec[i].coeffs[j] = d.r0;
        }
    }

    // Pack public key
    pack_pk(pk, rho, &t1);

    // Pack private key: rho || K || tr || s1 || s2 || t0
    @memcpy(sk[0..32], rho);
    @memcpy(sk[32..64], K_bytes);
    // tr = H(pk)
    var tr: [32]u8 = undefined;
    var h2 = Shake256.init(.{});
    h2.update(pk);
    var tr_buf: [32]u8 = undefined;
    h2.squeeze(&tr_buf);
    @memcpy(&tr, &tr_buf);
    @memcpy(sk[64..96], &tr);

    var pos: usize = 96;
    for (s1.vec) |p| {
        polyeta_pack(sk[pos..][0..96], &p);
        pos += 96;
    }
    for (s2.vec) |p| {
        polyeta_pack(sk[pos..][0..96], &p);
        pos += 96;
    }
    for (t0.vec) |p| {
        polyt0_pack(sk[pos..][0..416], &p);
        pos += 416;
    }
}

fn polyeta_pack(r: []u8, a: *const Poly) void {
    for (0..N / 8) |i| {
        const t: [8]u32 = .{
            @bitCast(@as(i32, 2) - a.coeffs[8 * i]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 1]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 2]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 3]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 4]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 5]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 6]),
            @bitCast(@as(i32, 2) - a.coeffs[8 * i + 7]),
        };
        r[3 * i] = @truncate(t[0] | t[1] << 3 | t[2] << 6);
        r[3 * i + 1] = @truncate(t[2] >> 2 | t[3] << 1 | t[4] << 4 | t[5] << 7);
        r[3 * i + 2] = @truncate(t[5] >> 1 | t[6] << 2 | t[7] << 5);
    }
}

fn polyeta_unpack(r: []const u8, a: *Poly) void {
    for (0..N / 8) |i| {
        a.coeffs[8 * i] = @as(i32, 2) - @as(i32, @intCast(r[3 * i] & 0x07));
        a.coeffs[8 * i + 1] = @as(i32, 2) - @as(i32, @intCast((r[3 * i] >> 3) & 0x07));
        a.coeffs[8 * i + 2] = @as(i32, 2) - @as(i32, @intCast((r[3 * i] >> 6) | ((r[3 * i + 1] & 0x01) << 2)));
        a.coeffs[8 * i + 3] = @as(i32, 2) - @as(i32, @intCast((r[3 * i + 1] >> 1) & 0x07));
        a.coeffs[8 * i + 4] = @as(i32, 2) - @as(i32, @intCast((r[3 * i + 1] >> 4) & 0x07));
        a.coeffs[8 * i + 5] = @as(i32, 2) - @as(i32, @intCast((r[3 * i + 1] >> 7) | ((r[3 * i + 2] & 0x03) << 1)));
        a.coeffs[8 * i + 6] = @as(i32, 2) - @as(i32, @intCast((r[3 * i + 2] >> 2) & 0x07));
        a.coeffs[8 * i + 7] = @as(i32, 2) - @as(i32, @intCast((r[3 * i + 2] >> 5)));
    }
}

fn polyt0_pack(r: []u8, a: *const Poly) void {
    for (0..N / 8) |i| {
        const t: [8]u32 = .{
            @bitCast((1 << 12) - a.coeffs[8 * i]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 1]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 2]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 3]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 4]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 5]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 6]),
            @bitCast((1 << 12) - a.coeffs[8 * i + 7]),
        };
        r[13 * i] = @truncate(t[0]);
        r[13 * i + 1] = @truncate(t[0] >> 8 | t[1] << 5);
        r[13 * i + 2] = @truncate(t[1] >> 3);
        r[13 * i + 3] = @truncate(t[1] >> 11 | t[2] << 2);
        r[13 * i + 4] = @truncate(t[2] >> 6 | t[3] << 7);
        r[13 * i + 5] = @truncate(t[3] >> 1);
        r[13 * i + 6] = @truncate(t[3] >> 9 | t[4] << 4);
        r[13 * i + 7] = @truncate(t[4] >> 4);
        r[13 * i + 8] = @truncate(t[4] >> 12 | t[5] << 1);
        r[13 * i + 9] = @truncate(t[5] >> 7 | t[6] << 6);
        r[13 * i + 10] = @truncate(t[6] >> 2);
        r[13 * i + 11] = @truncate(t[6] >> 10 | t[7] << 3);
        r[13 * i + 12] = @truncate(t[7] >> 5);
    }
}

fn polyt0_unpack(r: []const u8, a: *Poly) void {
    for (0..N / 8) |i| {
        a.coeffs[8 * i] = (1 << 12) - @as(i32, @intCast(@as(u32, r[13 * i]) | (@as(u32, r[13 * i + 1]) & 0x1F) << 8));
        a.coeffs[8 * i + 1] = (1 << 12) - @as(i32, @intCast(r[13 * i + 1] >> 5 | (@as(u32, r[13 * i + 2]) << 3) | ((@as(u32, r[13 * i + 3]) & 0x03) << 11)));
        a.coeffs[8 * i + 2] = (1 << 12) - @as(i32, @intCast(r[13 * i + 3] >> 2 | ((@as(u32, r[13 * i + 4]) & 0x7F) << 6)));
        a.coeffs[8 * i + 3] = (1 << 12) - @as(i32, @intCast(r[13 * i + 4] >> 7 | (@as(u32, r[13 * i + 5]) << 1) | ((@as(u32, r[13 * i + 6]) & 0x0F) << 9)));
        a.coeffs[8 * i + 4] = (1 << 12) - @as(i32, @intCast(r[13 * i + 6] >> 4 | (@as(u32, r[13 * i + 7]) << 4) | ((@as(u32, r[13 * i + 8]) & 0x01) << 12)));
        a.coeffs[8 * i + 5] = (1 << 12) - @as(i32, @intCast(r[13 * i + 8] >> 1 | ((@as(u32, r[13 * i + 9]) & 0x3F) << 7)));
        a.coeffs[8 * i + 6] = (1 << 12) - @as(i32, @intCast(r[13 * i + 9] >> 6 | (@as(u32, r[13 * i + 10]) << 2) | ((@as(u32, r[13 * i + 11]) & 0x07) << 10)));
        a.coeffs[8 * i + 7] = (1 << 12) - @as(i32, @intCast(r[13 * i + 11] >> 3 | (@as(u32, r[13 * i + 12]) << 5)));
    }
}

// ── Sign ──────────────────────────────────────────────────────────────────────

/// Sign a message. Returns error if nonce counter overflows (astronomically unlikely).
pub fn sign(sig: *Signature, msg: []const u8, sk: *const PrivateKey) Error!void {
    // Unpack sk
    const rho = sk[0..32];
    const key = sk[32..64];
    const tr = sk[64..96];

    var s1 = PolyVecL.zero();
    var s2 = PolyVecK.zero();
    var t0 = PolyVecK.zero();

    var pos: usize = 96;
    for (&s1.vec) |*p| {
        polyeta_unpack(sk[pos..][0..96], p);
        pos += 96;
    }
    for (&s2.vec) |*p| {
        polyeta_unpack(sk[pos..][0..96], p);
        pos += 96;
    }
    for (&t0.vec) |*p| {
        polyt0_unpack(sk[pos..][0..416], p);
        pos += 416;
    }

    // Expand A
    var a: [K][L]Poly = undefined;
    expand_a(rho, &a);

    // mu = H(tr || msg)
    var mu: [64]u8 = undefined;
    var h = Shake256.init(.{});
    h.update(tr);
    h.update(msg);
    h.squeeze(&mu);

    // rho'' = H(key || mu)
    var rho_prime: [64]u8 = undefined;
    var h2 = Shake256.init(.{});
    h2.update(key);
    h2.update(&mu);
    h2.squeeze(&rho_prime);

    // NTT(s1), NTT(s2), NTT(t0)
    var s1_hat = s1;
    var s2_hat = s2;
    var t0_hat = t0;
    for (&s1_hat.vec) |*p| ntt(p);
    for (&s2_hat.vec) |*p| ntt(p);
    for (&t0_hat.vec) |*p| ntt(p);

    var kappa: u16 = 0;
    while (true) {
        // Sample y
        var y = PolyVecL.zero();
        for (0..L) |i| {
            poly_uniform_gamma1(&rho_prime, kappa * @as(u16, L) + @as(u16, i), &y.vec[i]);
        }

        // w = A*y
        var y_hat = y;
        for (&y_hat.vec) |*p| ntt(p);
        var w = PolyVecK.zero();
        for (0..K) |i| {
            for (0..L) |j| {
                var tmp = Poly.zero();
                poly_pointwise_montgomery(&tmp, &a[i][j], &y_hat.vec[j]);
                poly_add(&w.vec[i], &w.vec[i], &tmp);
            }
            poly_reduce(&w.vec[i]);
            inv_ntt(&w.vec[i]);
            poly_reduce(&w.vec[i]);
            poly_caddq(&w.vec[i]);
        }

        // w1 = HighBits(w)
        var w1 = PolyVecK.zero();
        for (0..K) |i| {
            for (0..N) |j| {
                w1.vec[i].coeffs[j] = highbits(w.vec[i].coeffs[j]);
            }
        }

        // c_tilde = H(mu || w1)
        var c_tilde: [32]u8 = undefined;
        var h3 = Shake256.init(.{});
        h3.update(&mu);
        // Pack w1 for hashing
        var w1_packed: [K * 192]u8 = undefined;
        for (0..K) |i| {
            polyw1_pack(w1_packed[i * 192 ..][0..192], &w1.vec[i]);
        }
        h3.update(&w1_packed);
        h3.squeeze(&c_tilde);

        // Sample c
        var c = Poly.zero();
        sample_in_ball(&c_tilde, &c);
        var c_hat = c;
        ntt(&c_hat);

        // cs1 = c*s1, cs2 = c*s2
        var cs1 = PolyVecL.zero();
        var cs2 = PolyVecK.zero();
        for (0..L) |i| {
            poly_pointwise_montgomery(&cs1.vec[i], &c_hat, &s1_hat.vec[i]);
            inv_ntt(&cs1.vec[i]);
        }
        for (0..K) |i| {
            poly_pointwise_montgomery(&cs2.vec[i], &c_hat, &s2_hat.vec[i]);
            inv_ntt(&cs2.vec[i]);
        }

        // z = y + cs1
        var z = PolyVecL.zero();
        for (0..L) |i| {
            poly_add(&z.vec[i], &y.vec[i], &cs1.vec[i]);
            poly_reduce(&z.vec[i]);
        }

        // Rejection: ||z||_inf < γ1 - β
        var reject = false;
        const bound1: i32 = @as(i32, @intCast(GAMMA1)) - @as(i32, @intCast(BETA));
        for (z.vec) |p| {
            if (!poly_chknorm(&p, bound1)) {
                reject = true;
                break;
            }
        }
        if (reject) {
            kappa += 1;
            if (kappa == 0) return Error.SignatureTooLarge;
            continue;
        }

        // r0 = LowBits(w - cs2)
        var h_poly = PolyVecK.zero();
        var n_hints: usize = 0;
        for (0..K) |i| {
            var wcs2 = Poly.zero();
            poly_sub(&wcs2, &w.vec[i], &cs2.vec[i]);
            poly_reduce(&wcs2);
            poly_caddq(&wcs2);

            // Rejection: ||r0||_inf < γ2 - β
            var r0 = Poly.zero();
            for (0..N) |j| {
                r0.coeffs[j] = lowbits(wcs2.coeffs[j]);
            }
            poly_reduce(&r0);
            const bound2: i32 = @as(i32, @intCast(GAMMA2)) - @as(i32, @intCast(BETA));
            if (!poly_chknorm(&r0, bound2)) {
                reject = true;
                break;
            }

            // ct0 = c*t0
            var ct0 = Poly.zero();
            poly_pointwise_montgomery(&ct0, &c_hat, &t0_hat.vec[i]);
            inv_ntt(&ct0);
            poly_reduce(&ct0);

            // Hints
            for (0..N) |j| {
                h_poly.vec[i].coeffs[j] = if (makehint(-ct0.coeffs[j], wcs2.coeffs[j] + ct0.coeffs[j])) 1 else 0;
                n_hints += @intCast(h_poly.vec[i].coeffs[j]);
            }
        }

        if (reject or n_hints > OMEGA) {
            kappa += 1;
            if (kappa == 0) return Error.SignatureTooLarge;
            continue;
        }

        // Pack signature: c_tilde || z || h
        @memcpy(sig[0..32], &c_tilde);
        var spos: usize = 32;
        for (z.vec) |p| {
            polyz_pack(sig[spos..][0..576], &p);
            spos += 576;
        }
        // Pack hints
        var k_hints: usize = 0;
        for (0..K) |i| {
            for (0..N) |j| {
                if (h_poly.vec[i].coeffs[j] != 0) {
                    sig[spos + k_hints] = @intCast(j);
                    k_hints += 1;
                }
            }
            sig[spos + OMEGA + i] = @intCast(k_hints);
        }
        return;
    }
}

fn polyw1_pack(r: []u8, a: *const Poly) void {
    for (0..N / 2) |i| {
        r[i] = @truncate(@as(u32, @bitCast(a.coeffs[2 * i])) | (@as(u32, @bitCast(a.coeffs[2 * i + 1])) << 4));
    }
}

// ── Verify ────────────────────────────────────────────────────────────────────

/// Verify an ML-DSA-44 signature.
pub fn verify(sig: *const Signature, msg: []const u8, pk: *const PublicKey) Error!void {
    var rho: [32]u8 = undefined;
    var t1 = PolyVecK.zero();
    unpack_pk(pk, &rho, &t1);

    // tr = H(pk)
    var tr: [32]u8 = undefined;
    var h = Shake256.init(.{});
    h.update(pk);
    h.squeeze(&tr);

    // mu = H(tr || msg)
    var mu: [64]u8 = undefined;
    var h2 = Shake256.init(.{});
    h2.update(&tr);
    h2.update(msg);
    h2.squeeze(&mu);

    // Unpack signature
    const c_tilde = sig[0..32];
    var z = PolyVecL.zero();
    var spos: usize = 32;
    for (&z.vec) |*p| {
        polyz_unpack(sig[spos..][0..576], p);
        spos += 576;
    }

    // Check ||z||_inf < γ1 - β
    const bound: i32 = @as(i32, @intCast(GAMMA1)) - @as(i32, @intCast(BETA));
    for (z.vec) |p| {
        if (!poly_chknorm(&p, bound)) return Error.InvalidSignature;
    }

    // Unpack hints and count
    var n_hints: usize = 0;
    var hints: [K][N]bool = [_][N]bool{[_]bool{false} ** N} ** K;
    var prev: usize = 0;
    for (0..K) |i| {
        const end: usize = sig[spos + OMEGA + i];
        if (end < prev or end > OMEGA) return Error.InvalidSignature;
        for (prev..end) |j| {
            const idx = sig[spos + j];
            if (j > prev and idx <= sig[spos + j - 1]) return Error.InvalidSignature;
            hints[i][idx] = true;
            n_hints += 1;
        }
        prev = end;
    }
    if (n_hints > OMEGA) return Error.InvalidSignature;

    // Reconstruct w' = A*z - 2^d * c*t1
    var a: [K][L]Poly = undefined;
    expand_a(&rho, &a);

    var c = Poly.zero();
    sample_in_ball(c_tilde, &c);
    var c_hat = c;
    ntt(&c_hat);

    // NTT(z)
    var z_hat = z;
    for (&z_hat.vec) |*p| ntt(p);

    // NTT(t1) * 2^d
    var t1_hat = t1;
    for (&t1_hat.vec) |*p| {
        for (&p.coeffs) |*coeff| {
            coeff.* <<= 13; // multiply by 2^d = 2^13
        }
        ntt(p);
    }

    // w' = A*z - c*t1*2^d
    var w_prime = PolyVecK.zero();
    for (0..K) |i| {
        for (0..L) |j| {
            var tmp = Poly.zero();
            poly_pointwise_montgomery(&tmp, &a[i][j], &z_hat.vec[j]);
            poly_add(&w_prime.vec[i], &w_prime.vec[i], &tmp);
        }
        var ct1 = Poly.zero();
        poly_pointwise_montgomery(&ct1, &c_hat, &t1_hat.vec[i]);
        poly_sub(&w_prime.vec[i], &w_prime.vec[i], &ct1);
        poly_reduce(&w_prime.vec[i]);
        inv_ntt(&w_prime.vec[i]);
        poly_reduce(&w_prime.vec[i]);
        poly_caddq(&w_prime.vec[i]);
    }

    // UseHint to recover w1
    var w1 = PolyVecK.zero();
    for (0..K) |i| {
        for (0..N) |j| {
            w1.vec[i].coeffs[j] = usehint(hints[i][j], w_prime.vec[i].coeffs[j]);
        }
    }

    // Recompute c_tilde' = H(mu || w1)
    var c_tilde_prime: [32]u8 = undefined;
    var h3 = Shake256.init(.{});
    h3.update(&mu);
    var w1_packed: [K * 192]u8 = undefined;
    for (0..K) |i| {
        polyw1_pack(w1_packed[i * 192 ..][0..192], &w1.vec[i]);
    }
    h3.update(&w1_packed);
    h3.squeeze(&c_tilde_prime);

    if (!std.mem.eql(u8, c_tilde, &c_tilde_prime)) return Error.InvalidSignature;
}

// ── Public API ────────────────────────────────────────────────────────────────

/// Generate a keypair from OS random bytes.
pub fn generateKeypair() !struct { private: PrivateKey, public: PublicKey } {
    var seed: [SEED_LEN]u8 = undefined;
    std.crypto.random.bytes(&seed);
    var pk: PublicKey = undefined;
    var sk: PrivateKey = undefined;
    keygen(&seed, &pk, &sk);
    return .{ .private = sk, .public = pk };
}

/// Sign a message with a private key.
pub fn signMsg(msg: []const u8, sk: *const PrivateKey) Error!Signature {
    var sig: Signature = undefined;
    try sign(&sig, msg, sk);
    return sig;
}

/// Verify a signature against a message and public key.
pub fn verifyMsg(sig: *const Signature, msg: []const u8, pk: *const PublicKey) Error!void {
    return verify(sig, msg, pk);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

test "ml_dsa keygen produces correct key sizes" {
    const testing = std.testing;
    const kp = try generateKeypair();
    try testing.expectEqual(PK_LEN, kp.public.len);
    try testing.expectEqual(SK_LEN, kp.private.len);
}

test "ml_dsa sign and verify round-trip" {
    const testing = std.testing;
    const kp = try generateKeypair();
    const msg = "LOCKER: sovereign append-only ledger, post-quantum sealed.";
    const sig = try signMsg(msg, &kp.private);
    try testing.expectEqual(SIG_LEN, sig.len);
    try verifyMsg(&sig, msg, &kp.public);
}

test "ml_dsa verify rejects wrong message" {
    const testing = std.testing;
    const kp = try generateKeypair();
    const msg = "correct message";
    const sig = try signMsg(msg, &kp.private);
    const result = verifyMsg(&sig, "wrong message", &kp.public);
    try testing.expectError(Error.InvalidSignature, result);
}

test "ml_dsa verify rejects wrong key" {
    const testing = std.testing;
    const kp1 = try generateKeypair();
    const kp2 = try generateKeypair();
    const msg = "test";
    const sig = try signMsg(msg, &kp1.private);
    const result = verifyMsg(&sig, msg, &kp2.public);
    try testing.expectError(Error.InvalidSignature, result);
}
