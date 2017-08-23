import json
import streams
import os
import posix
import strutils
import sequtils
#

let input = newFileStream(stdin).parseJson("stdin")

proc findItem(node: JsonNode, searchItem: string, parent: JsonNode = nil): seq[JsonNode] =
    result = @[]
    case node.kind:
        of JArray:
            for child in node.getElems():
                let cResult = child.findItem(searchItem, node)
                if cResult != nil: result.add(cResult)
        of JObject:
            for key, child in node:
                if key == searchItem: result.add(node)
                else:
                    let cResult = child.findItem(searchItem, node)
                    if cResult != nil: result.add(cResult)
        of JString:
            if node.getStr() == searchItem: result.add(parent)
        else:
            if $node == searchItem: result.add(parent)

echo os.commandLineParams().map(
    proc(item: string): string = input.findItem(item).map(
        proc(j: JsonNode): string = j.pretty()
    ).join("\n-----\n")
).join("\n=====\n")

