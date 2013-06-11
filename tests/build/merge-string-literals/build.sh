# Special script used to check that LOCAL_SHORT_COMMANDS works
# correctly even when using a very large number of source files
# when building a static or shared library.
#
# We're going to auto-generate all the files we need in a
# temporary directory, because that's how we roll.
#

PROGDIR=$(dirname $0)
PROGDIR=$(cd "$PROGDIR" && pwd)

# Clean generated binaries
rm -rf "$PROGDIR/obj" "$PROGDIR/libs"

# Now run the build
$NDK/ndk-build -C "$PROGDIR" "$@"
RET=$?

# find objdump. Any arch's objdump can do "-s -j".  We just need to find one
# from $NDK/toolchains because MacOSX doesn't have that by default.
get_build_var ()
{
    make --no-print-dir -f $NDK/build/core/build-local.mk DUMP_$1 | tail -1
}

TOOLCHAIN_PREFIX=`get_build_var TOOLCHAIN_PREFIX`
OBJDUMP=${TOOLCHAIN_PREFIX}objdump

# check if linker.list is empty
ALL_SO=`find libs -name "*.so"`
for SO in $ALL_SO; do
    NUM_LINE=`$OBJDUMP -s -j.rodata $SO | wc -l | tr -d ' '`
    if [ "$NUM_LINE" != "7" ]; then
        echo "ERROR: Fail to merge string literals!"
        exit 1
    fi
    NUM_ABCD=`$OBJDUMP -s -j.rodata $SO | grep abcd | wc -l | tr -d ' '`
    if [ "$NUM_ABCD" != "2" ]; then
        echo "ERROR: abcd should appear exactly twice!"
        exit 1
    fi
done

# Clean generated binaries
rm -rf "$PROGDIR/obj" "$PROGDIR/libs"

# Exit
exit $RET