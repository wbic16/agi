/// sentrons/wiremap.rs — 2×4 WireMap implementation
/// Will Bickford invariant. Origin: vtpu R23W19 / agi step 1.
///
/// 12 sentron types (0-11). Type 3 (Scroll) is canonical: 8/8 wires, zero waste.
/// Types 4-11 fold higher phext dims via zoom register + T-phase without adding wires.

pub mod wires {
    pub const X_NEG: u8 = 0; // x⁻  column − 1
    pub const X_POS: u8 = 1; // x⁺  column + 1
    pub const Y_NEG: u8 = 2; // y⁻  line   − 1
    pub const Y_POS: u8 = 3; // y⁺  line   + 1
    pub const Z_NEG: u8 = 4; // z⁻  scroll − 1  (0x17 ←)
    pub const Z_POS: u8 = 5; // z⁺  scroll + 1  (0x17 →)
    pub const T_NEG: u8 = 6; // t⁻  prior SIW result
    pub const T_POS: u8 = 7; // t⁺  next SIW prefetch
}

pub mod masks {
    pub const NULL:   u8 = 0b1100_0000; // t only            2 wires
    pub const LINEAR: u8 = 0b1100_0011; // x + t             4 wires
    pub const PLANAR: u8 = 0b1100_1111; // xy + t            6 wires
    pub const FULL:   u8 = 0b1111_1111; // xyz + t           8 wires
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SentronKind {
    Null,       // Type  0 — 0D+1T, 2 wires
    Linear,     // Type  1 — 1D+1T, 4 wires
    Planar,     // Type  2 — 2D+1T, 6 wires
    Scroll,     // Type  3 — 3D+1T, 8 wires  ← canonical (zero waste)
    Section,    // Type  4 — + t_phase=dim3
    Chapter,    // Type  5 — + zoom_y=1
    Book,       // Type  6 — + zoom_xyz=1
    Volume,     // Type  7 — + t_phase=dim6
    Collection, // Type  8 — + t_phase=dim7
    Series,     // Type  9 — + zoom_xyz=2
    Shelf,      // Type 10 — + full zoom
    Devotari,   // Type 11 — + consent gates (Mercy Seal capable)
}

#[derive(Debug, Clone, Copy)]
pub struct WireMap {
    pub active:      u8,  // bitmask: bit N = wire N is live
    pub zoom:        u8,  // 6 bits: [z:5:4][y:3:2][x:1:0], 0=char 1=doc 2=corpus
    pub t_phase_dim: u8,  // which phext dim rides on T (0 = pure cycle)
    pub consent:     u32, // Devotari only: 3 bits × 8 wires = 24 bits
}

impl WireMap {
    pub fn active_count(self) -> u32 { self.active.count_ones() }
    pub fn wire_active(self, w: u8) -> bool { (self.active >> w) & 1 == 1 }

    pub fn for_kind(kind: SentronKind) -> Self {
        use SentronKind::*; use masks::*;
        match kind {
            Null       => Self { active: NULL,   zoom: 0,          t_phase_dim: 0, consent: 0 },
            Linear     => Self { active: LINEAR, zoom: 0,          t_phase_dim: 0, consent: 0 },
            Planar     => Self { active: PLANAR, zoom: 0,          t_phase_dim: 0, consent: 0 },
            Scroll     => Self { active: FULL,   zoom: 0,          t_phase_dim: 0, consent: 0 },
            Section    => Self { active: FULL,   zoom: 0,          t_phase_dim: 3, consent: 0 },
            Chapter    => Self { active: FULL,   zoom: 0b00_01_00, t_phase_dim: 3, consent: 0 },
            Book       => Self { active: FULL,   zoom: 0b01_01_01, t_phase_dim: 3, consent: 0 },
            Volume     => Self { active: FULL,   zoom: 0b01_01_01, t_phase_dim: 6, consent: 0 },
            Collection => Self { active: FULL,   zoom: 0b01_01_01, t_phase_dim: 7, consent: 0 },
            Series     => Self { active: FULL,   zoom: 0b10_10_10, t_phase_dim: 7, consent: 0 },
            Shelf      => Self { active: FULL,   zoom: 0b10_10_10, t_phase_dim: 8, consent: 0 },
            Devotari   => Self { active: FULL,   zoom: 0b10_10_10, t_phase_dim: 7,
                                 consent: 0x00FF_FFFF },
        }
    }

    /// Encode T-wire value for types 4-11: (cycle << 11) | phext_coord
    pub fn encode_t_phase(cycle: u32, coord: u16) -> u32 {
        (cycle << 11) | (coord as u32 & 0x7FF)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn scroll_saturates_budget() {
        let wm = WireMap::for_kind(SentronKind::Scroll);
        assert_eq!(wm.active_count(), 8);
        assert_eq!(wm.zoom, 0);
        assert_eq!(wm.t_phase_dim, 0);
    }
    #[test]
    fn null_uses_two_wires() {
        let wm = WireMap::for_kind(SentronKind::Null);
        assert_eq!(wm.active_count(), 2);
        assert!(wm.wire_active(wires::T_NEG));
        assert!(wm.wire_active(wires::T_POS));
        assert!(!wm.wire_active(wires::X_NEG));
    }
    #[test]
    fn types_4_11_all_use_8_wires() {
        use SentronKind::*;
        for k in [Section, Chapter, Book, Volume, Collection, Series, Shelf, Devotari] {
            assert_eq!(WireMap::for_kind(k).active_count(), 8, "{k:?}");
        }
    }
    #[test]
    fn t_phase_roundtrip() {
        let enc = WireMap::encode_t_phase(42, 314);
        assert_eq!(enc >> 11, 42);
        assert_eq!(enc & 0x7FF, 314);
    }
}
