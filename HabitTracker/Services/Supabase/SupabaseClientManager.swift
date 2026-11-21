//
//  SupabaseClientManager.swift
//  HabitTracker
//
//  Created by Minh Khoi on 19/11/26.
//

import Foundation
import Supabase


@MainActor
final class SupabaseClientManager: ObservableObject {
    static let shared = SupabaseClientManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: SupabaseConfig.projectURL,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
}

