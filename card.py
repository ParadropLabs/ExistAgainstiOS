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

    return dict(questions=q, answers=a)

def write(name, contents):
    with open(os.path.join(os.getcwd(), name), 'w') as f:
        r = json.dumps(contents)
        r = u'' + r.replace('{', '[').replace('}', ']')
        f.write(r.encode('utf-8'))

def main():
    j = None

    with open('cards_pg13.json', 'r') as f:
        j = process(json.loads(f.read()))
        write('processed_13.txt', j)

    with open('cards.txt', 'r') as f:
        j = process(json.loads(f.read()))
        write('processed.txt', j)

if __name__ == '__main__':
    main()