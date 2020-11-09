//
//  BetterProfessorTests.swift
//  BetterProfessorTests
//
//  Created by Hunter Oppel on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import XCTest
@testable import BetterProfessor

class BetterProfessorUITests: XCTestCase {

    let timeout: TimeInterval = 5

    func testNoServerResponse() {
        let expectation = self.expectation(description: "Server responds in reasonable time")
        let url = URL(string: "betterProfessor")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { expectation.fulfill() }
            XCTAssertNil(data)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
        }.resume()
        wait(for: [expectation], timeout: timeout)
    }

    func testServerResponse() {
        let url = URL(string: "https://betterprofessoruni.herokuapp.com")!
        let expectation = self.expectation(description: "Server responds in reasonable time")
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { expectation.fulfill() }
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
        }.resume()
        wait(for: [expectation], timeout: timeout)
    }

    func testSignUp() {
        let expectation = self.expectation(description: "User can sign up")
        BackendController.shared.signUp(username: "Stephanie", password: "password", department: "math", completion: { result, _, error in
            XCTAssertTrue(result)
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: timeout)
    }

    func testSingIn() {
        let expectation = self.expectation(description: "User can sign in")
        BackendController.shared.signIn(username: "Stephanie", password: "password", completion: { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: timeout)
    }

    func testCreateStudent() {

        let expectation1 = self.expectation(description: "User can sign in")
        BackendController.shared.signIn(username: "Stephanie", password: "password", completion: { _ in
            expectation1.fulfill()
            })
            wait(for: [expectation1], timeout: timeout)
        let expectation2 = self.expectation(description: "User can create a student")
        BackendController.shared.createStudentForInstructor(name: "Kumar", email: "Kumar@gmail.com", subject: "iOS") { result, error in
            XCTAssertTrue(result)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 5)
    }
    func testSignOut() {
        let expectation1 = self.expectation(description: "User can sign in")
        BackendController.shared.signIn(username: "Stephanie", password: "password", completion: { _ in
            expectation1.fulfill()
            })
            wait(for: [expectation1], timeout: timeout)

        let expectation2 = self.expectation(description: "User can sign out")
        BackendController.shared.signOut()
        expectation2.fulfill()
        wait(for: [expectation2], timeout: timeout)
    }
    func testFetchAllStudents() throws {
        let expectation1 = self.expectation(description: "User can sign in")
        BackendController.shared.signIn(username: "Stephanie", password: "password", completion: { _ in
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: timeout)

        let expectation2 = self.expectation(description: "Fetched all students")
        try BackendController.shared.fetchAllStudents { students, error in
            XCTAssertNil(error)
            XCTAssertNotNil(students)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: timeout)
    }

    func testEncoding() {
        let url = URL(string: "https://betterprofessoruni.herokuapp.com")!
        let expectation = self.expectation(description: "Data encodes from backend")
        URLSession.shared.dataTask(with: url) { data, response, error in
          XCTAssertNil(error)
        do {
            let response = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(response.statusCode, 200)

            let data = try XCTUnwrap(data)
            XCTAssertNoThrow(try JSONEncoder().encode(data))
          }
          catch { }
        }
        .resume()
        expectation.fulfill()
        waitForExpectations(timeout: timeout)
    }

    func testDecoding() {
        let url = URL(string: "https://betterprofessoruni.herokuapp.com")!
        let expectation = self.expectation(description: "Data decodes from the backend")
        URLSession.shared.dataTask(with: url) { data, response, error in
          XCTAssertNil(error)
          do {
            let response = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(response.statusCode, 200)

            let data = try XCTUnwrap(data)
            XCTAssertNoThrow(
              try JSONDecoder().decode([StudentRepresentation].self, from: data)
            )
          }
          catch { }
        }
        .resume()
        expectation.fulfill()
        waitForExpectations(timeout: timeout)
    }

    func testSpeedOfTypicalRequestsMoreAccurately() {

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let expectation = self.expectation(description: "Wait for results")
            let controller = BackendController(dataLoader: URLSession(configuration: .ephemeral))

            startMeasuring()
            controller.signIn(username: "Stephanie", password: "password", completion: { result in
                self.stopMeasuring()
                XCTAssert(result)
                expectation.fulfill()
            })
                wait(for: [expectation], timeout: 5)
            }
    }
}
