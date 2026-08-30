.code16
.section .fixture,"a"
.global initial_count
.global initial_members
.global last_selected_id
.global last_selected_index
.global remove_id

# Fixed-capacity bounded fixture. The fixture supplies facts only.
# It does not compact membership or choose the next member.
initial_count:
    .byte 3
initial_members:
    .byte 'A', 'B', 'C'
last_selected_id:
    .byte 'B'
last_selected_index:
    .byte 1
remove_id:
    .byte 'A'
