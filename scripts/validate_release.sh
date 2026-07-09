#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

ERRORS=0


fail()
{
    echo "[FAIL] $1"
    ERRORS=$((ERRORS+1))
}


pass()
{
    echo "[ OK ] $1"
}


echo "===================================="
echo " Clipboard Guardian Release Validator"
echo "===================================="
echo


########################################
# Structure
########################################

echo "Checking project structure..."

for path in \
    src \
    assets \
    packaging/debian \
    scripts \
    VERSION
do
    if [ -e "$ROOT_DIR/$path" ]; then
        pass "$path exists"
    else
        fail "$path missing"
    fi
done


echo


########################################
# Legacy detection
########################################

echo "Checking forbidden references..."

if grep -R -E \
"production|clipboard-checker|Clipboard Checker|edit-paste|src/legacy" \
"$ROOT_DIR" \
--exclude-dir=.git \
--exclude-dir=build \
--exclude-dir=dist \
--exclude-dir=__pycache__ \
--exclude="validate_release.sh" \
>/tmp/cg_legacy_check 2>/dev/null
then
    cat /tmp/cg_legacy_check
    fail "Legacy references found"
else
    pass "No legacy references"
fi


echo


########################################
# Python cache
########################################

echo "Checking python cache..."

if find "$ROOT_DIR/src" \
\( -name "__pycache__" -o -name "*.pyc" -o -name "*.pyo" \) \
| grep -q .
then

    find "$ROOT_DIR/src" \
    \( -name "__pycache__" -o -name "*.pyc" -o -name "*.pyo" \)

    fail "Python cache files found"

else
    pass "No python cache"
fi


echo


########################################
# Python syntax (no cache creation)
########################################

echo "Checking python syntax..."

if python3 - "$ROOT_DIR/src" <<'PY'
import pathlib
import py_compile
import sys
import tempfile

root = pathlib.Path(sys.argv[1])

for file in root.rglob("*.py"):
    py_compile.compile(
        str(file),
        doraise=True,
        cfile=tempfile.mktemp()
    )

print("syntax ok")
PY
then
    pass "Python syntax OK"
else
    fail "Python syntax errors"
fi


echo


########################################
# Debian packaging
########################################

echo "Checking Debian packaging..."

for file in \
    packaging/debian/control
do
    if [ -f "$ROOT_DIR/$file" ]
    then
        pass "$file exists"
    else
        fail "$file missing"
    fi
done


echo


########################################
# Version
########################################

echo "Checking version..."

VERSION=$(cat "$ROOT_DIR/VERSION")

if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
    pass "Version $VERSION"
else
    fail "Invalid version format"
fi


echo


########################################
# Build script
########################################

echo "Checking build script..."

if [ -x "$ROOT_DIR/scripts/build_deb.sh" ]
then
    pass "build_deb.sh executable"
else
    fail "build_deb.sh not executable"
fi


echo


########################################
# Icon
########################################

echo "Checking application icon..."

if [ -f "$ROOT_DIR/assets/icons/clipboard-guardian-green.png" ]
then
    pass "Application icon exists"
else
    fail "Application icon missing"
fi


echo


########################################
# Final
########################################

if [ "$ERRORS" -eq 0 ]
then
    echo "===================================="
    echo " RELEASE VALIDATION PASSED "
    echo "===================================="
    exit 0
else
    echo "===================================="
    echo " RELEASE VALIDATION FAILED "
    echo " Errors: $ERRORS"
    echo "===================================="
    exit 1
fi
