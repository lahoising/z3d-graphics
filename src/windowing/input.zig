const zglfw = @import("zglfw");

pub const Key = enum {
    ESCAPE,
    TAB,
    BACKTAB,
    BACKSPACE,
    RETURN,
    ENTER,
    INSERT,
    DELETE,
    PAUSE,
    PRINT,
    SYS_REQ,
    CLEAR,
    HOME,
    END,
    LEFT,
    UP,
    RIGHT,
    DOWN,
    PAGE_UP,
    PAGE_DOWN,
    SHIFT,
    CTRL,
    META,
    ALT,
    ALT_GR,
    CAPS_LOCK,
    NUM_LOCK,
    SCROLL_LOCK,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    F13,
    F14,
    F15,
    F16,
    F17,
    F18,
    F19,
    F20,
    F21,
    F22,
    F23,
    F24,
    F25,
    F26,
    F27,
    F28,
    F29,
    F30,
    F31,
    F32,
    F33,
    F34,
    F35,
    SUPER_L,
    SUPER_R,
    MENU,
    HYPER_L,
    HYPER_R,
    HELP,
    DIRECTION_L,
    DIRECTION_R,
    SPACE,
    ANY,
    EXCLAM,
    QUOTE_DBL,
    NUMBER_SIGN,
    DOLLAR,
    PERCENT,
    AMPERSAND,
    APOSTROPHE,
    PAREN_LEFT,
    PAREN_RIGHT,
    ASTERISK,
    PLUS,
    COMMA,
    MINUS,
    PERIOD,
    SLASH,
    NUM0,
    NUM1,
    NUM2,
    NUM3,
    NUM4,
    NUM5,
    NUM6,
    NUM7,
    NUM8,
    NUM9,
    COLON,
    SEMICOLON,
    LESS,
    EQUAL,
    GREATER,
    QUESTION,
    AT,
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    BRACKET_LEFT,
    BACKSLASH,
    BRACKET_RIGHT,
    ASCII_CIRCUM,
    UNDERSCORE,
    QUOTE_LEFT,
    BRACE_LEFT,
    BAR,
    BRACE_RIGHT,
    ASCII_TILDE,
    NOBREAKSPACE,
    EXCLAMDOWN,
    CENT,
    STERLING,
    CURRECNY,
    YEN,
    BROKENBAR,
    SECTION,
    DIAERESIS,
    COPYRIGHT,
    ORDFEMININE,
    GUILLEMOTLEFT,
    NOTSIGN,
    HYPHEN,
    REGISTERED,
    MACRON,
    DEGREE,
    PLUSMINUS,
    TWOSUPERIOR,
    THREESUPERIOR,
    ACUTE,
    MICRO,
    MU,
    PARAGRAPH,
    PERIODCENTERED,
    CEDILLA,
    ONESUPERIOR,
    MASCULINE,
    GUILLEMOTRIGHT,
    ONEQUARTER,
    ONEHALF,
    THREEQUARTERS,
    QUESTIONDOWN,
    A_GRAVE,
    A_ACUTE,
    A_CIRCUMFLEX,
    A_TILDE,
    A_DIAERESIS,
    A_RING,
    A_E,
    C_CEDILLA,
    E_GRACE,
    E_ACUTE,
    E_CURCUMFLEX,
    E_DIAERESIS,
    I_GRAVE,
    I_ACUTE,
    I_CIRCUMFLEX,
    I_DIAERESIS,
    ETH,
    N_TILDE,
    O_GRAVE,
    O_ACUTE,
    O_CIRCUMFLEX,
    O_TILDE,
    O_DIAERESIS,
    MULTIPLY,
    O_OBLIQUE,
    U_GRAVE,
    U_ACUTE,
    U_CIRCUMFLEX,
    U_DIAERESIS,
    Y_ACUTE,
    THORN,
    SSHARP,
    DIVISION,
    Y_DIAERESIS,
    MULTI_KEY,
    CODEINPUT,
    SINGLE_CANDIDATE,
    MULTIPLE_CANDIDATE,
    PREVIOUS_CANDIDATE,
    MODE_SWITCH,
    KANJI,
    MUHENKAN,
    HENKAN,
    ROMAJI,
    HIRAGANA,
    KATAKANA,
    HIRAGAN_KATAKANA,
    ZENKAKU,
    HANKAKU,
    ZENKAKU_HANKAKU,
    TOUROKU,
    MASSYO,
    KANA_LOCK,
    KANA_SHIFT,
    EISU_SHIFT,
    EISU_TOGGLE,
    HANGUL,
    HANGUL_START,
    HANGUL_END,
    HANGUL_HANJA,
    HANGUL_JAMO,
    HANGUL_ROMAJA,
    HANGUL_JEONJA,
    HANGUL_BANJA,
    HANGUL_PRE_HANJA,
    HANGUL_POST_HANJA,
    HANGUL_SPECIAL,
    DEAD_GRAVE,
    DEAD_ACUTE,
    DEAD_CIRCUMFLEX,
    DEAD_TILDE,
    DEAD_MACRON,
    DEAD_BREVE,
    DEAD_ABOVEDOT,
    DEAD_DIAERESIS,
    DEAD_ABOVERING,
    DEAD_DOUBLEACUTE,
    DEAD_CARON,
    DEAD_CEDILLA,
    DEAD_OGONEK,
    DEAD_IOTA,
    DEAD_VOICED_SOUND,
    DEAD_SEMIVOICED_SOUND,
    DEAD_BELOWDOT,
    DEAD_HOOK,
    DEAD_HORN,
    DEAD_STROKE,
    DEAD_ABOVECOMMA,
    DEAD_ABOVEREVERSEDCOMMA,
    DEAD_DOUBLEGRAVE,
    BACK,
    FORWARD,
    STOP,
    REFRESH,
    VOLUME_DOWN,
    VOLUME_MUTE,
    VOLUME_UP,
    BASS_BOOST,
    BASS_UP,
    BASS_DOWN,
    TREBLE_UP,
    TREBLE_DOWN,
    MEDIA_PLAY,
    MEDIA_STOP,
    MEDIA_PREVIOUS,
    MEDIA_NEXT,
    MEDIA_RECORD,
    MEDIA_PAUSE,
    MEDIA_TOGGLE_PLAY_PAUSE,
    HOME_PAGE,
    FAVORITES,
    SEARCH,
    STANDBY,
    OPEN_URL,
    MON_BRIGHTNESS_UP,
    MON_BRIGHTNESS_DOWN,
    KEYBOARD_LIGHT_ON_OFF,
    KEYBOARD_BRIGHTNESS_UP,
    KEYBOARD_BRIGHTNESS_DOWN,
    POWER_OFF,
    WAKE_UP,
    EJECT,
    SCREEN_SAVE,
};

pub const KeyModifier = struct {
    shift: bool,
    ctrl: bool,
    alt: bool,
    super: bool,
    keypad: bool,
    groupSwitch: bool,
};

pub const KeyAction = enum {
    PRESSED,
    RELEASED,
    REPEAT,
};

pub fn convertBackendKeyToKey(backendKey: zglfw.Key) Key {
    // TODO: some of these keys are not properly mapped
    return switch (backendKey) {
        zglfw.Key.escape => Key.ESCAPE,
        zglfw.Key.tab => Key.TAB,
        // glfw.GLFW_KEY_TAB => Key.BACKTAB,
        zglfw.Key.backspace => Key.BACKSPACE,
        // glfw.GLFW_KEY_ENTER => Key.RETURN,
        zglfw.Key.enter => Key.ENTER,
        zglfw.Key.insert => Key.INSERT,
        zglfw.Key.delete => Key.DELETE,
        zglfw.Key.pause => Key.PAUSE,
        zglfw.Key.print_screen => Key.PRINT,
        // glfw.GLFW_KEY_LEFT_SUPER => Key.SYS_REQ,
        // glfw.GLFW_KEY_BACKSPACE => Key.CLEAR,
        zglfw.Key.home => Key.HOME,
        zglfw.Key.end => Key.END,
        zglfw.Key.left => Key.LEFT,
        zglfw.Key.up => Key.UP,
        zglfw.Key.right => Key.RIGHT,
        zglfw.Key.down => Key.DOWN,
        zglfw.Key.page_up => Key.PAGE_UP,
        zglfw.Key.page_down => Key.PAGE_DOWN,
        zglfw.Key.left_shift => Key.SHIFT,
        zglfw.Key.left_control => Key.CTRL,
        // glfw.GLFW_KEY_LEFT_SUPER => Key.META,
        zglfw.Key.left_alt => Key.ALT,
        // glfw.GLFW_KEY_GRAVE_ACCENT => Key.ALT_GR,
        zglfw.Key.caps_lock => Key.CAPS_LOCK,
        zglfw.Key.num_lock => Key.NUM_LOCK,
        zglfw.Key.scroll_lock => Key.SCROLL_LOCK,
        zglfw.Key.F1 => Key.F1,
        zglfw.Key.F2 => Key.F2,
        zglfw.Key.F3 => Key.F3,
        zglfw.Key.F4 => Key.F4,
        zglfw.Key.F5 => Key.F5,
        zglfw.Key.F6 => Key.F6,
        zglfw.Key.F7 => Key.F7,
        zglfw.Key.F8 => Key.F8,
        zglfw.Key.F9 => Key.F9,
        zglfw.Key.F10 => Key.F10,
        zglfw.Key.F11 => Key.F11,
        zglfw.Key.F12 => Key.F12,
        zglfw.Key.F13 => Key.F13,
        zglfw.Key.F14 => Key.F14,
        zglfw.Key.F15 => Key.F15,
        zglfw.Key.F16 => Key.F16,
        zglfw.Key.F17 => Key.F17,
        zglfw.Key.F18 => Key.F18,
        zglfw.Key.F19 => Key.F19,
        zglfw.Key.F20 => Key.F20,
        zglfw.Key.F21 => Key.F21,
        zglfw.Key.F22 => Key.F22,
        zglfw.Key.F23 => Key.F23,
        zglfw.Key.F24 => Key.F24,
        zglfw.Key.F25 => Key.F25,
        // glfw.GLFW_KEY_F26 => Key.F26,
        // glfw.GLFW_KEY_F27 => Key.F27,
        // glfw.GLFW_KEY_F28 => Key.F28,
        // glfw.GLFW_KEY_F29 => Key.F29,
        // glfw.GLFW_KEY_F30 => Key.F30,
        // glfw.GLFW_KEY_F31 => Key.F31,
        // glfw.GLFW_KEY_F32 => Key.F32,
        // glfw.GLFW_KEY_F33 => Key.F33,
        // glfw.GLFW_KEY_F34 => Key.F34,
        // glfw.GLFW_KEY_F35 => Key.F35,
        zglfw.Key.left_super => Key.SUPER_L,
        zglfw.Key.right_super => Key.SUPER_R,
        zglfw.Key.menu => Key.MENU,
        // glfw.GLFW_KEY_LEFT_SHIFT => Key.HYPER_L,
        // glfw.GLFW_KEY_RIGHT_SHIFT => Key.HYPER_R,
        // glfw.GLFW_KEY_LEFT => Key.DIRECTION_L,
        // glfw.GLFW_KEY_RIGHT => Key.DIRECTION_R,
        zglfw.Key.space => Key.SPACE,
        // glfw.GLFW_KEY_1 => Key.EXCLAM,
        // glfw.GLFW_KEY_APOSTROPHE => Key.QUOTE_DBL,
        // glfw.GLFW_KEY_3 => Key.NUMBER_SIGN,
        // glfw.GLFW_KEY_4 => Key.DOLLAR,
        // glfw.GLFW_KEY_5 => Key.PERCENT,
        // glfw.GLFW_KEY_7 => Key.AMPERSAND,
        zglfw.Key.apostrophe => Key.APOSTROPHE,
        // glfw.GLFW_KEY_9 => Key.PAREN_LEFT,
        // glfw.GLFW_KEY_0 => Key.PAREN_RIGHT,
        // glfw.GLFW_KEY_8 => Key.ASTERISK,
        // glfw.GLFW_KEY_EQUAL => Key.PLUS,
        zglfw.Key.comma => Key.COMMA,
        zglfw.Key.minus => Key.MINUS,
        zglfw.Key.period => Key.PERIOD,
        zglfw.Key.slash => Key.SLASH,
        zglfw.Key.zero => Key.NUM0,
        zglfw.Key.one => Key.NUM1,
        zglfw.Key.two => Key.NUM2,
        zglfw.Key.three => Key.NUM3,
        zglfw.Key.four => Key.NUM4,
        zglfw.Key.five => Key.NUM5,
        zglfw.Key.six => Key.NUM6,
        zglfw.Key.seven => Key.NUM7,
        zglfw.Key.eight => Key.NUM8,
        zglfw.Key.nine => Key.NUM9,
        // glfw.GLFW_KEY_SEMICOLON => Key.COLON,
        zglfw.Key.semicolon => Key.SEMICOLON,
        // glfw.GLFW_KEY_COMMA => Key.LESS,
        zglfw.Key.equal => Key.EQUAL,
        // glfw.GLFW_KEY_PERIOD => Key.GREATER,
        // glfw.GLFW_KEY_SLASH => Key.QUESTION,
        // glfw.GLFW_KEY_2 => Key.AT,
        zglfw.Key.a => Key.A,
        zglfw.Key.b => Key.B,
        zglfw.Key.c => Key.C,
        zglfw.Key.d => Key.D,
        zglfw.Key.e => Key.E,
        zglfw.Key.f => Key.F,
        zglfw.Key.g => Key.G,
        zglfw.Key.h => Key.H,
        zglfw.Key.i => Key.I,
        zglfw.Key.j => Key.J,
        zglfw.Key.k => Key.K,
        zglfw.Key.l => Key.L,
        zglfw.Key.m => Key.M,
        zglfw.Key.n => Key.N,
        zglfw.Key.o => Key.O,
        zglfw.Key.p => Key.P,
        zglfw.Key.q => Key.Q,
        zglfw.Key.r => Key.R,
        zglfw.Key.s => Key.S,
        zglfw.Key.t => Key.T,
        zglfw.Key.u => Key.U,
        zglfw.Key.v => Key.V,
        zglfw.Key.w => Key.W,
        zglfw.Key.x => Key.X,
        zglfw.Key.y => Key.Y,
        zglfw.Key.z => Key.Z,
        zglfw.Key.left_bracket => Key.BRACKET_LEFT,
        zglfw.Key.backslash => Key.BACKSLASH,
        zglfw.Key.right_bracket => Key.BRACKET_RIGHT,
        // glfw.GLFW_KEY_MENU => Key.ASCII_CIRCUM,
        // glfw.GLFW_KEY_MINUS => Key.UNDERSCORE,
        // glfw.GLFW_KEY_ESCAPE => Key.QUOTE_LEFT,
        // glfw.GLFW_KEY_ESCAPE => Key.BRACE_LEFT,
        // glfw.GLFW_KEY_ESCAPE => Key.BAR,
        // glfw.GLFW_KEY_ESCAPE => Key.BRACE_RIGHT,
        // glfw.GLFW_KEY_ESCAPE => Key.ASCII_TILDE,
        // glfw.GLFW_KEY_ESCAPE => Key.NOBREAKSPACE,
        // glfw.GLFW_KEY_ESCAPE => Key.EXCLAMDOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.CENT,
        // glfw.GLFW_KEY_ESCAPE => Key.STERLING,
        // glfw.GLFW_KEY_ESCAPE => Key.CURRECNY,
        // glfw.GLFW_KEY_ESCAPE => Key.YEN,
        // glfw.GLFW_KEY_ESCAPE => Key.BROKENBAR,
        // glfw.GLFW_KEY_ESCAPE => Key.SECTION,
        // glfw.GLFW_KEY_ESCAPE => Key.DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.COPYRIGHT,
        // glfw.GLFW_KEY_ESCAPE => Key.ORDFEMININE,
        // glfw.GLFW_KEY_ESCAPE => Key.GUILLEMOTLEFT,
        // glfw.GLFW_KEY_ESCAPE => Key.NOTSIGN,
        // glfw.GLFW_KEY_ESCAPE => Key.HYPHEN,
        // glfw.GLFW_KEY_ESCAPE => Key.REGISTERED,
        // glfw.GLFW_KEY_ESCAPE => Key.MACRON,
        // glfw.GLFW_KEY_ESCAPE => Key.DEGREE,
        // glfw.GLFW_KEY_ESCAPE => Key.PLUSMINUS,
        // glfw.GLFW_KEY_ESCAPE => Key.TWOSUPERIOR,
        // glfw.GLFW_KEY_ESCAPE => Key.THREESUPERIOR,
        // glfw.GLFW_KEY_ESCAPE => Key.ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.MICRO,
        // glfw.GLFW_KEY_ESCAPE => Key.MU,
        // glfw.GLFW_KEY_ESCAPE => Key.PARAGRAPH,
        // glfw.GLFW_KEY_ESCAPE => Key.PERIODCENTERED,
        // glfw.GLFW_KEY_ESCAPE => Key.CEDILLA,
        // glfw.GLFW_KEY_ESCAPE => Key.ONESUPERIOR,
        // glfw.GLFW_KEY_ESCAPE => Key.MASCULINE,
        // glfw.GLFW_KEY_ESCAPE => Key.GUILLEMOTRIGHT,
        // glfw.GLFW_KEY_ESCAPE => Key.ONEQUARTER,
        // glfw.GLFW_KEY_ESCAPE => Key.ONEHALF,
        // glfw.GLFW_KEY_ESCAPE => Key.THREEQUARTERS,
        // glfw.GLFW_KEY_ESCAPE => Key.QUESTIONDOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.A_GRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.A_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.A_CIRCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.A_TILDE,
        // glfw.GLFW_KEY_ESCAPE => Key.A_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.A_RING,
        // glfw.GLFW_KEY_ESCAPE => Key.A_E,
        // glfw.GLFW_KEY_ESCAPE => Key.C_CEDILLA,
        // glfw.GLFW_KEY_ESCAPE => Key.E_GRACE,
        // glfw.GLFW_KEY_ESCAPE => Key.E_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.E_CURCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.E_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.I_GRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.I_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.I_CIRCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.I_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.ETH,
        // glfw.GLFW_KEY_ESCAPE => Key.N_TILDE,
        // glfw.GLFW_KEY_ESCAPE => Key.O_GRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.O_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.O_CIRCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.O_TILDE,
        // glfw.GLFW_KEY_ESCAPE => Key.O_DIAERESIS,
        zglfw.Key.kp_multiply => Key.MULTIPLY,
        // glfw.GLFW_KEY_ESCAPE => Key.O_OBLIQUE,
        // glfw.GLFW_KEY_ESCAPE => Key.U_GRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.U_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.U_CIRCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.U_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.Y_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.THORN,
        // glfw.GLFW_KEY_ESCAPE => Key.SSHARP,
        zglfw.Key.kp_divide => Key.DIVISION,
        // glfw.GLFW_KEY_ESCAPE => Key.Y_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.MULTI_KEY,
        // glfw.GLFW_KEY_ESCAPE => Key.CODEINPUT,
        // glfw.GLFW_KEY_ESCAPE => Key.SINGLE_CANDIDATE,
        // glfw.GLFW_KEY_ESCAPE => Key.MULTIPLE_CANDIDATE,
        // glfw.GLFW_KEY_ESCAPE => Key.PREVIOUS_CANDIDATE,
        // glfw.GLFW_KEY_ESCAPE => Key.MODE_SWITCH,
        // glfw.GLFW_KEY_ESCAPE => Key.KANJI,
        // glfw.GLFW_KEY_ESCAPE => Key.MUHENKAN,
        // glfw.GLFW_KEY_ESCAPE => Key.HENKAN,
        // glfw.GLFW_KEY_ESCAPE => Key.ROMAJI,
        // glfw.GLFW_KEY_ESCAPE => Key.HIRAGANA,
        // glfw.GLFW_KEY_ESCAPE => Key.KATAKANA,
        // glfw.GLFW_KEY_ESCAPE => Key.HIRAGAN_KATAKANA,
        // glfw.GLFW_KEY_ESCAPE => Key.ZENKAKU,
        // glfw.GLFW_KEY_ESCAPE => Key.HANKAKU,
        // glfw.GLFW_KEY_ESCAPE => Key.ZENKAKU_HANKAKU,
        // glfw.GLFW_KEY_ESCAPE => Key.TOUROKU,
        // glfw.GLFW_KEY_ESCAPE => Key.MASSYO,
        // glfw.GLFW_KEY_ESCAPE => Key.KANA_LOCK,
        // glfw.GLFW_KEY_ESCAPE => Key.KANA_SHIFT,
        // glfw.GLFW_KEY_ESCAPE => Key.EISU_SHIFT,
        // glfw.GLFW_KEY_ESCAPE => Key.EISU_TOGGLE,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_START,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_END,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_HANJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_JAMO,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_ROMAJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_JEONJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_BANJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_PRE_HANJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_POST_HANJA,
        // glfw.GLFW_KEY_ESCAPE => Key.HANGUL_SPECIAL,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_GRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_ACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_CIRCUMFLEX,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_TILDE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_MACRON,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_BREVE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_ABOVEDOT,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_DIAERESIS,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_ABOVERING,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_DOUBLEACUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_CARON,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_CEDILLA,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_OGONEK,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_IOTA,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_VOICED_SOUND,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_SEMIVOICED_SOUND,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_BELOWDOT,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_HOOK,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_HORN,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_STROKE,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_ABOVECOMMA,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_ABOVEREVERSEDCOMMA,
        // glfw.GLFW_KEY_ESCAPE => Key.DEAD_DOUBLEGRAVE,
        // glfw.GLFW_KEY_ESCAPE => Key.BACK,
        // glfw.GLFW_KEY_ESCAPE => Key.FORWARD,
        // glfw.GLFW_KEY_ESCAPE => Key.STOP,
        // glfw.GLFW_KEY_ESCAPE => Key.REFRESH,
        // glfw.GLFW_KEY_ESCAPE => Key.VOLUME_DOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.VOLUME_MUTE,
        // glfw.GLFW_KEY_ESCAPE => Key.VOLUME_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.BASS_BOOST,
        // glfw.GLFW_KEY_ESCAPE => Key.BASS_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.BASS_DOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.TREBLE_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.TREBLE_DOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_PLAY,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_STOP,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_PREVIOUS,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_NEXT,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_RECORD,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_PAUSE,
        // glfw.GLFW_KEY_ESCAPE => Key.MEDIA_TOGGLE_PLAY_PAUSE,
        // glfw.GLFW_KEY_ESCAPE => Key.HOME_PAGE,
        // glfw.GLFW_KEY_ESCAPE => Key.FAVORITES,
        // glfw.GLFW_KEY_ESCAPE => Key.SEARCH,
        // glfw.GLFW_KEY_ESCAPE => Key.STANDBY,
        // glfw.GLFW_KEY_ESCAPE => Key.OPEN_URL,
        // glfw.GLFW_KEY_ESCAPE => Key.MON_BRIGHTNESS_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.MON_BRIGHTNESS_DOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.KEYBOARD_LIGHT_ON_OFF,
        // glfw.GLFW_KEY_ESCAPE => Key.KEYBOARD_BRIGHTNESS_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.KEYBOARD_BRIGHTNESS_DOWN,
        // glfw.GLFW_KEY_ESCAPE => Key.POWER_OFF,
        // glfw.GLFW_KEY_ESCAPE => Key.WAKE_UP,
        // glfw.GLFW_KEY_ESCAPE => Key.EJECT,
        // glfw.GLFW_KEY_ESCAPE => Key.SCREEN_SAVE,
        else => Key.ANY,
    };
}

pub fn convertBackendKeyModifierToKeyModifier(backendKeyModifier: zglfw.Mods) KeyModifier {
    return KeyModifier{
        .shift = backendKeyModifier.shift,
        .ctrl = backendKeyModifier.control,
        .alt = backendKeyModifier.alt,
        .super = backendKeyModifier.super,
        .keypad = backendKeyModifier.num_lock,
        .groupSwitch = backendKeyModifier.caps_lock,
    };
}

pub fn convertBackendKeyActionToKeyAction(backendKeyAction: zglfw.Action) KeyAction {
    return switch (backendKeyAction) {
        zglfw.Action.press => KeyAction.PRESSED,
        zglfw.Action.release => KeyAction.RELEASED,
        zglfw.Action.repeat => KeyAction.REPEAT,
    };
}
