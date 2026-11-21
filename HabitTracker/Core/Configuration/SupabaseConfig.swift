//
//  SupabaseConfig.swift
//  HabitTracker
//
//  Created by Minh Khoi on 19/11/26.
//

import Foundation

enum SupabaseConfig {
    private static let secretsDict: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict
        }
        return nil
    }()

    static var projectURL: URL {
        // 1. Check local untracked Secrets.plist
        if let urlString = secretsDict?["SUPABASE_URL"] as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return url
        }

        // 2. Check Info.plist / xcconfig
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return url
        }

        // 3. Check environment variable (CI or Xcode scheme)
        if let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return url
        }

        #if DEBUG
        print("⚠️ [SupabaseConfig] SUPABASE_URL not found. Ensure Secrets.plist exists or set SUPABASE_URL in Info.plist / environment.")
        #endif
        return URL(string: "https://placeholder.supabase.co")!
    }

    static var anonKey: String {
        // 1. Check local untracked Secrets.plist
        if let key = secretsDict?["SUPABASE_ANON_KEY"] as? String,
           !key.isEmpty {
            return key
        }

        // 2. Check Info.plist / xcconfig
        if let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
           !key.isEmpty {
            return key
        }

        // 3. Check environment variable (CI or Xcode scheme)
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
           !key.isEmpty {
            return key
        }

        #if DEBUG
        print("⚠️ [SupabaseConfig] SUPABASE_ANON_KEY not found. Ensure Secrets.plist exists or set SUPABASE_ANON_KEY in Info.plist / environment.")
        #endif
        return ""
    }
}
