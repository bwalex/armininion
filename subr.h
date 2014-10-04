#ifndef _SUBR_H
#define _SUBR_H
#include <stdarg.h>

#define NULL ((void *)0)

typedef unsigned char u_char;
#define MAXNBUF	256

typedef unsigned short	u_short;
typedef unsigned long	u_long;
typedef unsigned int	u_int;
typedef	long int	intptr_t;
typedef	long unsigned int	uintptr_t;
typedef long unsigned int	size_t;
typedef long int		ssize_t;
typedef long int	intmax_t;
typedef long unsigned int	uintmax_t;
typedef intptr_t	ptrdiff_t;
typedef unsigned long	uint64_t;
typedef long		int64_t;
typedef unsigned int	uint32_t;
typedef int		int32_t;
typedef unsigned short	uint16_t;
typedef short		int16_t;
typedef unsigned char	uint8_t;
typedef char		int8_t;
typedef uint64_t	u_int64_t;
typedef uint64_t	quad_t;

#define hex2ascii(hex) (hex2ascii_data[hex])
extern char const hex2ascii_data[];

#define	HD_COLUMN_MASK	0xff
#define	HD_DELIM_MASK	0xff00
#define	HD_OMIT_COUNT	(1 << 16)
#define	HD_OMIT_HEX	(1 << 17)
#define	HD_OMIT_CHARS	(1 << 18)


#define isspace(c)	((c) == ' ' || ((c) >= '\t' && (c) <= '\r'))
#define isascii(c)	(((c) & ~0x7f) == 0)
#define isupper(c)	((c) >= 'A' && (c) <= 'Z')
#define islower(c)	((c) >= 'a' && (c) <= 'z')
#define isalpha(c)	(isupper(c) || islower(c))
#define isdigit(c)	((c) >= '0' && (c) <= '9')
#define isxdigit(c)	(isdigit(c) \
			  || ((c) >= 'A' && (c) <= 'F') \
			  || ((c) >= 'a' && (c) <= 'f'))
#define isprint(c)	((c) >= ' ' && (c) <= '~')

#define toupper(c)	((c) - 0x20 * (((c) >= 'a') && ((c) <= 'z')))
#define tolower(c)	((c) + 0x20 * (((c) >= 'A') && ((c) <= 'Z')))



static __inline int imax(int a, int b) { return (a > b ? a : b); }
static __inline int imin(int a, int b) { return (a < b ? a : b); }
static __inline long lmax(long a, long b) { return (a > b ? a : b); }
static __inline long lmin(long a, long b) { return (a < b ? a : b); }
static __inline u_int umax(u_int a, u_int b) { return (a > b ? a : b); }
static __inline u_int umin(u_int a, u_int b) { return (a < b ? a : b); }
static __inline u_int max(u_int a, u_int b) { return (a > b ? a : b); }
static __inline u_int min(u_int a, u_int b) { return (a < b ? a : b); }
static __inline quad_t qmax(quad_t a, quad_t b) { return (a > b ? a : b); }
static __inline quad_t qmin(quad_t a, quad_t b) { return (a < b ? a : b); }
static __inline u_long ulmax(u_long a, u_long b) { return (a > b ? a : b); }
static __inline u_long ulmin(u_long a, u_long b) { return (a < b ? a : b); }
static __inline u_int64_t u64max(u_int64_t a, u_int64_t b) { return (a > b ? a : b); }
static __inline u_int64_t u64min(u_int64_t a, u_int64_t b) { return (a < b ? a : b); }
static __inline int64_t i64max(int64_t a, int64_t b) { return (a > b ? a : b); }
static __inline int64_t i64min(int64_t a, int64_t b) { return (a < b ? a : b); }
static __inline size_t szmax(size_t a, size_t b) { return (a > b ? a : b); }
static __inline size_t szmin(size_t a, size_t b) { return (a < b ? a : b); }

static __inline int abs(int a) { return (a < 0 ? -a : a); }
static __inline long labs(long a) { return (a < 0 ? -a : a); }
static __inline quad_t qabs(quad_t a) { return (a < 0 ? -a : a); }

size_t strlen(const char *str);
int kprintf(const char *fmt, ...);
int kvprintf(const char *fmt, va_list ap);
int ksprintf(char *buf, const char *cfmt, ...);
int kvsprintf(char *buf, const char *cfmt, va_list ap);
int ksnprintf(char *str, size_t size, const char *format, ...);
int kvsnprintf(char *str, size_t size, const char *format, va_list ap);
int kvsnrprintf(char *str, size_t size, int radix, const char *format, va_list ap);
int kvcprintf(char const *fmt, void (*func)(int, void*), void *arg, int radix, va_list ap);
void hexdump(const void *ptr, int length, const char *hdr, int flags);
#endif
