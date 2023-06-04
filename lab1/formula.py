# a, b, c, d, e = list(map(lambda x: int(x), input().split()))

a = int(input('a = '))
b = int(input('b = '))
c = int(input('c = '))
d = int(input('d = '))
e = int(input('e = '))

print(( a*(b+c) - d*(a+e) ) / (d**2 - c**2 * b))
