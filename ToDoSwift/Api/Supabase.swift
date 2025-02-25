//
//  Supabase.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 23/02/25.
//

import Foundation
import Supabase

let supabase = SupabaseClient(supabaseURL: URL(string: "https://mcovfelitcuqlbohhpaq.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jb3ZmZWxpdGN1cWxib2hocGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAzMzAzNDYsImV4cCI6MjA1NTkwNjM0Nn0.8cjq33znuNKxZsISSnQq1tImRKZOLQ_IwvplEux-BEE")

let auth = supabase.auth
