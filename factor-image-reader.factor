
USING: kernel io system assocs destructors
       io.encodings.binary io.files io.binary
       namespaces sequences math ;
IN: factor-image-reader

CONSTANT: header-cells 10
CONSTANT: userenv-cells 70
SYMBOLS: header-keys userenv-keys ;
TUPLE: 32LE ;
TUPLE: 32BE ;
TUPLE: 64LE ;
TUPLE: 64BE ;

{ "magic" "version" "data_relocation_base" "data_size" "code_relocation_base"
  "code_size" "true_object" "bignum_zero" "bignum_pos_one" "bignum_neg_one" }
header-keys set

{ "namestack_env" "catchstack_env" "current_callback_env" "walker_hook_env"
  "callcc_1_env" "break_env" "error_env" "cell_size_env" "cpu_env" "os_env"
  "args_env" "stdin_env" "stdout_env" "image_env" "executable_env"
  "embedded_env" "eval_callback_env" "yield_callback_env" "sleep_callback_env"
  "cocoa_exception_env" "boot_env" "global_env" "nothing0" "jit_prolog"
  "jit_primitive_word" "jit_primitive" "jit_word_jump" "jit_word_call"
  "jit_word_special" "jit_if_word" "jit_if" "jit_epilog" "jit_return"
  "jit_profiling" "jit_push_immediate" "jit_dip_word" "jit_dip" "jit_2dip_word"
  "jit_2dip" "jit_3dip_word" "jit_3dip" "jit_execute_word" "jit_execute_jump"
  "jit_execute_call" "jit_declare_word" "callback_stub" "nothing1" "pic_load"
  "pic_tag" "pic_hi_tag" "pic_tuple" "pic_hi_tag_tuple" "pic_check_tag"
  "pic_check" "pic_hit" "pic_miss_word" "pic_miss_tail_word" "mega_lookup"
  "mega_lookup_word" "mega_miss_word" "undefined_env" "stderr_env" "stage2_env"
  "current_thread_env" "threads_env" "run_queue_env" "sleep_queue_env"
  "nothing2" "nothing3" "nothing4" }
userenv-keys set

<PRIVATE

GENERIC# bytes>cell 2 ( cell_type stream bytes -- cell_type stream cell )

M: 32LE bytes>cell le> ;
M: 32BE bytes>cell be> ;
M: 64LE bytes>cell le> ;
M: 64BE bytes>cell be> ;

GENERIC# cell-size 1 ( cell_type stream -- cell_type stream size )

M: 32LE cell-size 4 ;
M: 32BE cell-size 4 ;
M: 64LE cell-size 8 ;
M: 64BE cell-size 8 ;

: seek-from-start ( stream pos -- stream )
    seek-absolute pick stream-seek ;
: skip-nothing ( cell_type stream -- cell_type stream )
    0 seek-from-start ;
: skip-header ( cell_type stream -- cell_type stream )
    cell-size header-cells * seek-from-start ;
: skip-userenv ( cell_type stream -- cell_type stream )
    header-cells userenv-cells +
    [ cell-size ] dip * seek-from-start ;
: next-cell ( cell_type stream -- cell_type stream cell )
    dup [ cell-size ] dip stream-read bytes>cell ;
: read-cell-into-assoc ( cell_type stream pairs key -- cell_type stream pairs )
    [ next-cell ] 2dip swapd pick set-at ;

PRIVATE>

! 32LE "factor.image" init header . userenv . done

: init ( cell_type_class path -- cell_type stream )
    binary <file-reader> [ new ] dip ;
: done ( cell_type stream -- )
    dispose drop ;
: header ( cell_type stream -- cell_type stream pairs )
    skip-nothing H{ }
    header-keys get [ read-cell-into-assoc ] each ;
: userenv ( cell_type stream -- cell_type stream pairs )
    skip-header H{ }
    userenv-keys get [ read-cell-into-assoc ] each ;
: count-data-objects ( cell_type stream -- cell_type stream total )
    header [ skip-userenv ] dip drop 0 ;

