
USING: kernel io system assocs destructors
       io.encodings.binary io.files io.binary
       namespaces sequences math ;
IN: factor-image-reader

SYMBOLS: header-keys ;

{ "magic" "version" "data_relocation_base" "data_size" "code_relocation_base"
      "code_size" "true_object" "bignum_zero" "bignum_pos_one" "bignum_neg_one" 
      "NAMESTACK_ENV" "CATCHSTACK_ENV" "CURRENT_CALLBACK_ENV" "WALKER_HOOK_ENV"
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
header-keys set

<PRIVATE

: seek-from-start ( stream pos -- stream )
    seek-absolute pick stream-seek ;

GENERIC# skip-header 1 ( arch stream -- arch stream )
GENERIC# next-cell 1 ( arch stream -- arch stream cell )
GENERIC# set-header-value 3 ( arch stream pairs key -- arch stream pairs )

M: x86.32 skip-header
    320 seek-from-start ;
M: x86.32 next-cell
    dup 4 swap stream-read le> ;
M: x86.32 set-header-value
    [ next-cell ] 2dip swapd pick set-at ;

PRIVATE>

: init ( path -- arch stream ) cpu swap binary <file-reader> ;
: done ( arch stream -- ) dispose drop ;
: header ( arch stream -- arch stream pairs )
    0 seek-from-start
    H{ }
    header-keys get [ set-header-value ] each ;
