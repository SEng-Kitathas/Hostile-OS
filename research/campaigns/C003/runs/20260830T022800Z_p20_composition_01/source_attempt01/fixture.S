.code16
.section .fixture,"a"
.global owner_a_fact
.global owner_b_fact
.global old_value_fact
.global new_value_fact
.global known_request_fact
.global missing_request_fact
.global continuation_fact
owner_a_fact:.byte 'A'
owner_b_fact:.byte 'B'
old_value_fact:.byte 'X'
new_value_fact:.byte 'Y'
known_request_fact:.byte 'K'
missing_request_fact:.byte 'U'
continuation_fact:.byte 2
