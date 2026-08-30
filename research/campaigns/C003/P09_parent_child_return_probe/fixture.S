.code16
.section .fixture,"a"
.global parent_identity_fact
.global child_identity_fact
.global good_lineage_parent_fact
.global bad_lineage_parent_fact
.global wait_target_fact
.global child_status_fact
.global initial_parent_progress_fact

parent_identity_fact: .byte 'P'
child_identity_fact: .byte 'C'
good_lineage_parent_fact: .byte 'P'
bad_lineage_parent_fact: .byte 'Q'
wait_target_fact: .byte 'C'
child_status_fact: .byte 'S'
initial_parent_progress_fact: .byte '0'
