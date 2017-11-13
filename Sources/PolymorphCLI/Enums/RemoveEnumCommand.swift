//
//  EnumRemoveCommand.swift
//  PolymorphCLI
//
//  Created by Benoit BRIATTE on 07/08/2017.
//

import Foundation
import PolymorphCore
import CommandLineArgs

public class RemoveEnumCommand: Command {

    public enum Keys {
        public static let name: String = "name"
        public static let force: String = "force"
    }

    public enum Options {
        public static let name = OptionDefinition(name: Keys.name, type: .string, isRequired: true, documentation: "The enum name")
        public static let force = OptionDefinition(name: Keys.force, type: .boolean, alias: "f", defaultValue: false, documentation: "Force to remove the enum")
    }

    public enum Consts {
        public static let name: String = "rm"
    }

    public lazy var definition: CommandDefinition = {
        return CommandDefinition(name: Consts.name, options: [
            Options.force,
            PolymorphCommand.Options.file,
            PolymorphCommand.Options.help
            ], main: Options.name, documentation: "Remove an enum")
    }()

    public func run(_ arguments: [String: Any]) throws {
        guard
            let file = arguments[PolymorphCommand.Keys.file] as? String,
            let name = arguments[Keys.name] as? String else {
                return
        }

        let project = try ProjectStorage.open(at: file)

        guard let target = project.models.findEnum(name: name) else {
            throw PolymorphCLIError.enumNotFound(name: name)
        }

        if let force = arguments[Keys.force] as? Bool, force == false {
            let used = project.models.searchClasses(linkedTo: target.id)
            guard used.count == 0 else {
                print("The \(name) enum is linked to other classes :")
                print(used.map { $0.help() }.joined(separator: "\n"))
                print("Use the --force option to remove it")
                return
            }
        }

        guard project.models.removeEnum(uuid: target.id) else {
            throw PolymorphCLIError.objectNotFound(name: target.id.uuidString)
        }

        try ProjectStorage.save(project: project, at: file)
    }
}
