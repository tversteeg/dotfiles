#include QMK_KEYBOARD_H

enum layers {
	LA_MAIN,
	LA_SYMBOLS,
	LA_FUNCTIONS,
	LA_MOUSE,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[LA_MAIN] = LAYOUT(
		// Left row 1
		KC_QUOT, KC_COMM, KC_DOT, KC_P, KC_Y,
		// Right row 1
		KC_F, KC_G, KC_C, KC_R, KC_L,

		// Left row 2
		LGUI_T(KC_A), LALT_T(KC_O), LSFT_T(KC_E), LCTL_T(KC_U), KC_I,
		// Right row 2
		KC_D, RCTL_T(KC_H), RSFT_T(KC_T), LALT_T(KC_N), RGUI_T(KC_S),

		// Left row 3
		KC_SCLN, KC_Q, KC_J, KC_K, KC_X,
		// Right row 3
		KC_B, KC_M, KC_W, KC_V, KC_Z,

		// Left thumb cluster
		LT(LA_MOUSE, KC_ESC), KC_SPACE,
		// Right thumb cluster
		LT(LA_SYMBOLS, KC_ENTER), LT(LA_FUNCTIONS, KC_BACKSPACE)),
	[LA_SYMBOLS] = LAYOUT(
		// Left row 1
		KC_GRAVE, KC_LEFT_BRACKET, KC_LCBR, KC_LPRN, KC_EXLM,
		// Right row 1
		KC_QUES, KC_RPRN, KC_RCBR, KC_RIGHT_BRACKET, KC_MINS,

		// Left row 2
		KC_1, KC_2, KC_3, KC_4, KC_5,
		// Right row 2
		KC_6, KC_7, KC_8, KC_9, KC_0,

		// Left row 3
		KC_TILD, KC_AT, KC_HASH, KC_DLR, KC_PERC,
		// Right row 3
		KC_CIRC, KC_AMPR, KC_ASTR, KC_UNDS, KC_EQL,

		// Left thumb cluster
		KC_SLSH, KC_BSLS,
		// Right thumb cluster
		KC_NO, KC_NO),
	[LA_MOUSE] = LAYOUT(
		// Left row 1
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 1
		KC_MS_ACCEL2, KC_MS_BTN1, KC_MS_WH_UP, KC_MS_BTN2, KC_NO,

		// Left row 2
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 2
		KC_MS_ACCEL1, KC_MS_LEFT, KC_MS_DOWN, KC_MS_UP, KC_MS_RIGHT,

		// Left row 3
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 3
		KC_MS_ACCEL0, KC_NO, KC_MS_WH_DOWN, KC_NO, KC_NO,

		// Left thumb cluster
		TO(LA_MAIN), KC_NO,
		// Right thumb cluster
		KC_NO, KC_NO),
	[LA_FUNCTIONS] = LAYOUT(
		// Left row 1
		KC_F1, KC_F2, KC_F3, KC_F4, KC_F5,
		// Right row 1
		KC_F6, KC_F7, KC_F8, KC_F9, KC_F10,

		// Left row 2
		KC_F11, KC_F12, KC_PRINT_SCREEN, KC_CAPS_LOCK, KC_NO,
		// Right row 2
		KC_MEDIA_PLAY_PAUSE, KC_LEFT, KC_DOWN, KC_UP, KC_RIGHT,

		// Left row 3
		KC_NO, KC_NO, KC_PAGE_DOWN, KC_PAGE_UP, KC_NO,
		// Right row 3
		KC_MEDIA_NEXT_TRACK, KC_CUT, KC_COPY, KC_PASTE, KC_NO,

		// Left thumb cluster
		KC_DEL, KC_TAB,
		// Right thumb cluster
		KC_NO, KC_NO)
/*
	[] = LAYOUT(
		// Left row 1
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 1
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left row 2
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 2
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left row 3
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
		// Right row 3
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left thumb cluster
		KC_NO, KC_NO,
		// Right thumb cluster
		KC_NO, KC_NO),
*/
};
