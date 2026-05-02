-- All knobs in one place. Hot-reload with F5 in-game.
-- Numbers are intentionally first-pass; tune by feel.

return {
  -- ===== Resource model =====
  -- Linear recovery curve: at stat=0, refresh=10% of max; at stat=100, 20%.
  recovery = {
    min_stat = 0,
    max_stat = 100,
    min_pct = 0.10,
    max_pct = 0.20,
  },

  -- ===== Default characters =====
  -- A balanced fighter and a balanced enemy for v0.
  player = {
    name = "Ren",
    vitality = 150,
    stamina = 60,
    magic   = 60,
    spirit  = 40,
    agility = 55,
    has_veil = true,  -- enable Veil command for testing routing
  },

  enemy = {
    name = "Bramble Wraith",
    vitality = 220,
    stamina = 40,
    magic   = 40,
    spirit  = 30,
    agility = 35,
  },

  -- ===== Agility differential =====
  -- Final window seconds = base_window * (1 + k * (atkAgi - defAgi) / 100)
  -- Clamped to [min_window, max_window]. Differential of +50 ⇒ +50% width.
  agility = {
    k = 1.0,
    min_window = 0.05,  -- 50ms hard floor
    max_window = 0.60,
  },

  -- ===== Chain Strikes =====
  chain = {
    -- Single demo move: Triple Cut (3 hits)
    demo = {
      id = "triple_cut",
      name = "Triple Cut",
      hits = 3,
      cost_active_hp = 18,
      base_damage_per_hit = 12,
      hit_interval = 0.55,    -- seconds between prompts
      base_window = 0.30,     -- pre-Agility window radius (seconds either side of impact)
      counter_window_per_hit = 0.45,  -- duration of vulnerability the defender sees
    },
    grades = {
      perfect_radius = 0.10,  -- within 10% of base_window from center = Perfect
      perfect_mult = 1.0,
      good_mult = 0.55,
      miss_mult = 0.0,
    },
  },

  -- ===== Defense / Counter =====
  defense = {
    telegraph_time = 1.10,    -- enemy wind-up before strike
    base_window = 0.40,       -- defender base window radius
    parry_radius = 0.06,      -- frame-tight at center
    guard_radius = 0.18,      -- still inside base
    -- Late press inside window edges = Stagger; outside = Hit.
    stagger_extra = 0.10,     -- band beyond base window that counts as Stagger
    counter = {
      base_window = 0.30,     -- perfect counter window radius
      perfect_radius = 0.06,
      counter_attack_damage = 26,
      counter_attack_cost_hp = 12,
    },
    enemy_basic = {
      damage = 28,
      type = "physical",
    },
    guard_damage_pct = 0.35,
    stagger_damage_pct = 0.75,
  },

  -- ===== Rhythm Magic =====
  rhythm = {
    demo_spell = {
      id = "spark",
      name = "Spark",
      element = "fire",
      damage_type = "elemental",
      base_damage = 60,
      cost_active_mp = 22,
      bpm = 110,
      notes = 6,
      lead_in = 1.5,           -- silence before first note
      hit_window = 0.18,       -- pre-Agility window radius around each note
    },
    grades = {
      -- thresholds against fraction of perfect hits in the song
      s = 1.00,
      a = 0.80,
      b = 0.60,
      c = 0.30,
      -- damage multipliers
      mult = { s = 1.30, a = 1.00, b = 0.80, c = 0.55, fail = 0.0 },
      fail_refund_pct = 0.50,  -- partial Active MP refund on fail
    },
  },

  -- ===== Mana Veil =====
  veil = {
    -- Toggle is a free action on the player's turn.
    toggle_cost = 0,
  },

  -- ===== Misc =====
  misc = {
    log_lines = 8,
  },
}
