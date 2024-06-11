import re

with open('whisper.cpp/ggml-vector.h') as f:
  prototypes = f.read()
prototypes = [line.replace(';', '') for line in prototypes.split('\n')
              if line.endswith(';') and not line.startswith('//') and '(' in line]
FUNCS = [(re.search(r'(?<= )\w+', proto).group(0), proto)
         for proto in prototypes]

# BEGIN SPECIAL FUNCTIONS
# FUNCS.append(('ggml_validate_row_data', 'bool ggml_validate_row_data(enum ggml_type type, const void * data, size_t nbytes)'))
# END SPECIAL FUNCTIONS

ARCHS = (
  ('amd_avx512bf16', '__x86_64__', ('X86_HAVE(FMA)', 'X86_HAVE(F16C)', 'X86_HAVE(AVX2)', 'X86_HAVE(AVX512F)', 'X86_HAVE(AVX512VL)', 'X86_HAVE(AVX512_BF16)')),
  ('amd_avx512', '__x86_64__', ('X86_HAVE(FMA)', 'X86_HAVE(F16C)', 'X86_HAVE(AVX2)', 'X86_HAVE(AVX512F)')),
  ('amd_avx2', '__x86_64__', ('X86_HAVE(FMA)', 'X86_HAVE(F16C)', 'X86_HAVE(AVX2)')),
  ('amd_f16c', '__x86_64__', ('X86_HAVE(F16C)',)),
  ('amd_fma', '__x86_64__', ('X86_HAVE(FMA)',)),
  ('amd_avx', '__x86_64__', ()),
  ('arm82', '__aarch64__', ('(getauxval(AT_HWCAP) & HWCAP_FPHP)', '(getauxval(AT_HWCAP) & HWCAP_ASIMDHP)')),
  ('arm80', '__aarch64__', ()),
)

for arch, mac, needs in ARCHS:
  path = 'whisper.cpp/ggml-vector-%s.c' % (arch.replace('_', '-'))
  with open(path, 'w') as f:
    f.write('#ifdef %s\n' % (mac))
    for func, proto in FUNCS:
      f.write('#define %s %s_%s\n' % (func, func, arch))
    f.write('#define GGML_VECTOR\n')
    f.write('#include "ggml-vector.inc"\n')
    f.write('#endif // %s\n' % (mac))

with open('whisper.cpp/ggml-vector.cpp', 'w') as f:
  f.write('#include <cosmo.h>\n')
  f.write('#include <sys/auxv.h>\n')
  f.write('#include <libc/sysv/consts/hwcap.h>\n')
  f.write('#include "ggml-vector.h"\n')
  f.write('\n')
  for func, proto in FUNCS:
    for arch, mac, needs in ARCHS:
      f.write('extern "C" %s;\n' % (proto.replace(func, '%s_%s' % (func, arch))))
    f.write('\n')
  f.write('static const struct VectorFuncs {\n')
  for func, proto in FUNCS:
    f.write('    typeof(%s) *ptr_%s;\n' % (func, func))
  f.write('\n')
  f.write('    VectorFuncs() {\n')
  for arch, mac, needs in ARCHS:
    f.write('#ifdef %s\n' % (mac))
    f.write('        if (%s) {\n' % (' && '.join(needs) or '1'))
    for func, proto in FUNCS:
      f.write('            ptr_%s = %s_%s;\n' % (func, func, arch))
    f.write('            return;\n')
    f.write('        }\n')
    f.write('#endif\n')
  f.write('    }\n')
  f.write('} funcs;\n')
  f.write('\n')
  for func, proto in FUNCS:
    proto = proto.replace(';', '')
    args = [s.split(' ')[-1] for s in re.search(r'(?<=\().*(?=\))', proto).group(0).split(',')]
    f.write(proto + ' {\n')
    f.write('  return funcs.ptr_%s(%s);\n' % (func, ', '.join(args)))
    f.write('}\n')
    f.write('\n')
