from ...helpers import get_allowed
import ast
import json
import os
import subprocess
import web

class UpdatePluginCommandR:
    """
    This endpoint is for updating a existing plugin repository on a Vent machine.
    """
    allow_origin, rest_url = get_allowed.get_allowed()
    def OPTIONS(self):
        return self.POST()

    def POST(self):
        web.header('Access-Control-Allow-Origin', self.allow_origin)
        data = web.data()
        payload = {}
        try:
            payload = ast.literal_eval(data)
            if type(payload) != dict:
                payload = ast.literal_eval(json.loads(data))
        except:
            return "malformed json body"

        # TODO add --engine-label(s) vent specific labels
        engine_labels = "--engine-label vcontrol_managed=yes "
        try:
            if "machine" in payload.keys():
                if "url" in payload.keys():
                    url = payload["url"]
                    cmd1 = "/usr/local/bin/docker-machine ssh "+payload["machine"]+" \"python2.7 /data/plugin_parser.py remove_plugins "+url+"\""
                    cmd2 = "/usr/local/bin/docker-machine ssh "+payload["machine"]+" \"python2.7 /data/plugin_parser.py add_plugins "+url+"\""
                    output = subprocess.check_output(cmd1, shell=True)
                    output = output + subprocess.check_output(cmd2, shell=True)
                    if output == "":
                        output = "successfully updated "+url
                else:
                    output = "failed to update "+url+" -- no url specified"
            else:
                output = "failed to update "+url+" -- no machine specified"
        except Exception as e:
        	output = str(e)
        return output
