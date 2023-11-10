#include QMK_KEYBOARD_H

#include "/tmp/password.h"

#ifndef PASSWORD
#error "PASSWORD not defined"
#endif

#define TH(key) LT(ZERO, key)

enum layers {
	LA_MAIN,
	LA_SYMBOLS,
	LA_FUNCTIONS,
	LA_GAME,
	// Zero is a special layer for acting like tap dance
	ZERO
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
		TH(KC_ESCAPE), KC_SPACE,
		// Right thumb cluster
		LT(LA_SYMBOLS, KC_ENTER), LT(LA_FUNCTIONS, KC_BACKSPACE)),
	[LA_SYMBOLS] = LAYOUT(
		// Left row 1
		KC_GRAVE, KC_LEFT_BRACKET, KC_LCBR, KC_LPRN, KC_EXLM,
		// Right row 1
		KC_QUES, KC_RPRN, KC_RCBR, KC_RIGHT_BRACKET, KC_MINS,

		// Left row 2
		TH(KC_1), TH(KC_2), TH(KC_3), TH(KC_4), TH(KC_5),
		// Right row 2
		TH(KC_6), TH(KC_7), TH(KC_8), TH(KC_9), TH(KC_0),

		// Left row 3
		KC_TILD, KC_AT, KC_HASH, KC_DLR, KC_PERC,
		// Right row 3
		KC_CIRC, KC_AMPR, KC_ASTR, KC_UNDS, KC_EQL,

		// Left thumb cluster
		KC_SLSH, KC_BSLS,
		// Right thumb cluster
		KC_NO, KC_NO),
	[LA_FUNCTIONS] = LAYOUT(
		// Left row 1
		KC_NO, KC_NO, KC_PRINT_SCREEN, KC_CAPS_LOCK, QK_BOOTLOADER,
		// Right row 1
		PB_1, KC_HOME, KC_PAGE_DOWN, KC_PAGE_UP, KC_END,

		// Left row 2
		KC_NO, KC_NO, KC_PIPE, KC_PLUS, KC_NO,
		// Right row 2
		KC_MEDIA_PLAY_PAUSE, KC_LEFT, KC_DOWN, KC_UP, KC_RIGHT,

		// Left row 3
		KC_F11, KC_F12, KC_NO, KC_NO, KC_NO,
		// Right row 3
		KC_MEDIA_NEXT_TRACK, KC_CUT, KC_COPY, KC_PASTE, TO(LA_GAME),

		// Left thumb cluster
		KC_DEL, KC_TAB,
		// Right thumb cluster
		KC_NO, KC_NO),
	[LA_GAME] = LAYOUT(
		// Left row 1
		KC_TAB, KC_Q, KC_W, KC_E, KC_R,
		// Right row 1
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left row 2
		KC_LEFT_SHIFT, KC_A, KC_S, KC_D, KC_F,
		// Right row 2
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left row 3
		KC_LEFT_CTRL, KC_Z, KC_X, KC_C, KC_V,
		// Right row 3
		KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,

		// Left thumb cluster
		KC_ESC, KC_SPACE,
		// Right thumb cluster
		TO(LA_MAIN), TO(LA_MAIN)),
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

// Tap-hold helper for keys
static bool process_tap_or_long_press_key(keyrecord_t* record, uint16_t long_press_keycode) {
	if (record->tap.count == 0) {
		// Key is being held
		if (record->event.pressed) {
			tap_code16(long_press_keycode);
		}

		// Skip default handling
		return false;
	}

	// Continue default handling
	return true;
}

// Tap-hold helper for functions
static bool process_tap_or_long_press_call_function(keyrecord_t* record, void (*func_to_call)(void)) {
	if (record->tap.count == 0) {
		// Key is being held
		if (record->event.pressed) {
			(*func_to_call)();
		}

		// Skip default handling
		return false;
	}

	// Continue default handling
	return true;
}

bool process_record_user(uint16_t keycode, keyrecord_t* record) {
	switch (keycode) {
		case TH(KC_ESC):
			return process_tap_or_long_press_call_function(record, &caps_word_toggle);
		case TH(KC_1):
			return process_tap_or_long_press_key(record, KC_F1);
		case TH(KC_2):
			return process_tap_or_long_press_key(record, KC_F2);
		case TH(KC_3):
			return process_tap_or_long_press_key(record, KC_F3);
		case TH(KC_4):
			return process_tap_or_long_press_key(record, KC_F4);
		case TH(KC_5):
			return process_tap_or_long_press_key(record, KC_F5);
		case TH(KC_6):
			return process_tap_or_long_press_key(record, KC_F6);
		case TH(KC_7):
			return process_tap_or_long_press_key(record, KC_F7);
		case TH(KC_8):
			return process_tap_or_long_press_key(record, KC_F8);
		case TH(KC_9):
			return process_tap_or_long_press_key(record, KC_F9);
		case TH(KC_0):
			return process_tap_or_long_press_key(record, KC_F10);
		case PB_1:
			if (record->event.pressed) {
				SEND_STRING(PASSWORD);
			}
			return false;
	}

	return true;
}
