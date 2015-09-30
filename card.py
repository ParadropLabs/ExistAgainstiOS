'''
Quick card conversion
'''

import json
import os

i = 0

def process(j):
    global i

    q, a = [], []

    for x in j:
        x.pop(u'expansion', None)
        x[u'id'] = i

        q.append(x) if x[u'cardType'] == u'Q' else a.append(x)
        x.pop(u'cardType', None)

        i += 1

    return q, a

def write(name, contents):
    with open(os.path.join(os.getcwd(), name), 'w') as f:
        r = json.dumps(contents)
        # r = u'' + r.replace('{', '[').replace('}', ']')
        f.write(r.encode('utf-8'))

def main():
    j = None

    with open('cards_pg13.json', 'r') as f:
        q, a = process(json.loads(f.read()))
        write('q13.json', q)
        write('a13.json', a)

    with open('cards.txt', 'r') as f:
        q, a = process(json.loads(f.read()))
        write('q21.json', q)
        write('a21.json', a)


if __name__ == '__main__':
    main()