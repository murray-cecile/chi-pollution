import json
import requests

AOT_API_ROOT = "https://api.arrayofthings.org/api/nodes"


def define_request():
    '''
    Takes: nothing?
    Returns: request for Chicago noise intensity from AoT API
    '''

    p = {'project': 'chicago',
        'size': 500}

    r = requests.get(AOT_API_ROOT, params = p)

    if r.raise_for_status():
        return '{}'    
    else:
        return r


def parse_response(r):
    '''
    Takes: request response
    Returns: dictionary ready for writing to JSON
    '''

    rj = r.json()

    parsed = []

    for n in rj['data']:
        parsed.append({'address': n['address']})

    return parsed


def make_html_options(parsed):
    '''
    Takes: list of dicts of addresses
    Returns: nothing
    Outputs a text file with the html text for all nodes
    '''

    with open("app/node_dropdown.txt", 'w') as f:

        for p in parsed:
            s = '<option value="{}">{}</option>\n'.format(p['address'], p['address'])
            f.write(s)

    return

if __name__ == "__main__":
    
    r = define_request()
    parsed = parse_response(r)
    print(parsed[0])

    # parsed_as_json = json.dumps(parsed)

    # with open("app/node_addresses.json", 'w') as outfile:
    #     json.dump(parsed_as_json, outfile)

    make_html_options(parsed)