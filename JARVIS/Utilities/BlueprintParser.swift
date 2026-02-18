//
//  BlueprintParser.swift
//  JARVIS
//
//  Parses JSON blueprints from JARVIS AI responses.
//  Extracts embedded JSON from mixed text+JSON responses.
//

import Foundation

/// Handles parsing of Blueprint JSON from AI responses.
struct BlueprintParser {
    
    /// Attempts to extract and parse a Blueprint from an AI response string.
    /// The response may contain both text and embedded JSON.
    static func parse(from response: String) -> (text: String, blueprint: Blueprint?) {
        // Try to find JSON in the response
        guard let jsonRange = findJSONRange(in: response) else {
            return (text: response.trimmingCharacters(in: .whitespacesAndNewlines), blueprint: nil)
        }
        
        let jsonString = String(response[jsonRange])
        let textBeforeJSON = String(response[response.startIndex..<jsonRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let textAfterJSON = String(response[jsonRange.upperBound..<response.endIndex])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullText = [textBeforeJSON, textAfterJSON]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        
        let blueprint = decodeBlueprint(from: jsonString)
        
        return (text: fullText, blueprint: blueprint)
    }
    
    /// Decodes a Blueprint from a JSON string.
    static func decodeBlueprint(from jsonString: String) -> Blueprint? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        
        // Try decoding as a full Blueprint first
        if let blueprint = try? decoder.decode(Blueprint.self, from: data) {
            return blueprint
        }
        
        // Try decoding as a single component and wrapping it in a blueprint
        if let component = try? decoder.decode(BlueprintComponent.self, from: data) {
            return Blueprint(
                type: .card,
                components: [component]
            )
        }
        
        return nil
    }
    
    /// Finds the range of a JSON object in a string by matching braces.
    private static func findJSONRange(in text: String) -> Range<String.Index>? {
        // Look for the first '{' that starts a JSON object
        guard let startIdx = text.firstIndex(of: "{") else { return nil }
        
        var braceCount = 0
        var endIdx: String.Index?
        var inString = false
        var escapeNext = false
        
        for idx in text.indices[startIdx...] {
            let char = text[idx]
            
            if escapeNext {
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            if char == "\"" {
                inString.toggle()
                continue
            }
            
            if inString { continue }
            
            if char == "{" {
                braceCount += 1
            } else if char == "}" {
                braceCount -= 1
                if braceCount == 0 {
                    endIdx = text.index(after: idx)
                    break
                }
            }
        }
        
        guard let end = endIdx else { return nil }
        return startIdx..<end
    }
}

