
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

{ "NAMESTACK_ENV" "CATCHSTACK_ENV" "CURRENT_CALLBACK_ENV" "WALKER_HOOK_ENV"
  "CALLCC_1_ENV" "BREAK_ENV" "ERROR_ENV" "CELL_SIZE_ENV" "CPU_ENV"
  "OS_ENV" "ARGS_ENV" "STDIN_ENV" "STDOUT_ENV" "IMAGE_ENV" "EXECUTABLE_ENV"
  "EMBEDDED_ENV" "EVAL_CALLBACK_ENV" "YIELD_CALLBACK_ENV" "SLEEP_CALLBACK_ENV"
  "COCOA_EXCEPTION_ENV" "BOOT_ENV" "GLOBAL_ENV" "NOTHING0" "JIT_PROLOG" "JIT_PRIMITIVE_WORD"
  "JIT_PRIMITIVE" "JIT_WORD_JUMP" "JIT_WORD_CALL" "JIT_WORD_SPECIAL" "JIT_IF_WORD"
  "JIT_IF" "JIT_EPILOG" "JIT_RETURN" "JIT_PROFILING" "JIT_PUSH_IMMEDIATE"
  "JIT_DIP_WORD" "JIT_DIP" "JIT_2DIP_WORD" "JIT_2DIP" "JIT_3DIP_WORD"
  "JIT_3DIP" "JIT_EXECUTE_WORD" "JIT_EXECUTE_JUMP" "JIT_EXECUTE_CALL"
  "JIT_DECLARE_WORD" "CALLBACK_STUB" "NOTHING1" "PIC_LOAD" "PIC_TAG" "PIC_HI_TAG"
  "PIC_TUPLE" "PIC_HI_TAG_TUPLE" "PIC_CHECK_TAG" "PIC_CHECK" "PIC_HIT"
  "PIC_MISS_WORD" "PIC_MISS_TAIL_WORD" "MEGA_LOOKUP" "MEGA_LOOKUP_WORD"
  "MEGA_MISS_WORD" "UNDEFINED_ENV" "STDERR_ENV" "STAGE2_ENV"
  "CURRENT_THREAD_ENV" "THREADS_ENV" "RUN_QUEUE_ENV" "SLEEP_QUEUE_ENV"
  "NOTHING2" "NOTHING3" "NOTHING4" }
userenv-keys set

<PRIVATE

GENERIC# seq>cell 2 ( cell_type stream seq -- cell_type stream cell )

M: 32LE seq>cell le> ;
M: 32BE seq>cell be> ;
M: 64LE seq>cell le> ;
M: 64BE seq>cell be> ;

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
    dup [ cell-size ] dip stream-read seq>cell ;
: read-cell-into-assoc ( cell_type stream pairs key -- cell_type stream pairs )
    [ next-cell ] 2dip swapd pick set-at ;

PRIVATE>

! 32LE "factor.image" init header . userenv . done

: init ( cell_type_class path -- cell_type stream )
    binary <file-reader> [ new ] dip ;
: done ( cell_type stream -- )
    dispose drop ;
: header ( cell_type stream -- cell_type stream pairs )
    skip-nothing
    H{ }
    header-keys get [ read-cell-into-assoc ] each ;
: userenv ( cell_type stream -- cell_type stream pairs )
    skip-header
    H{ }
    userenv-keys get [ read-cell-into-assoc ] each ;
: count-data-objects ( cell_type stream -- cell_type stream total )
    header [ skip-userenv ] dip drop 0 ;

