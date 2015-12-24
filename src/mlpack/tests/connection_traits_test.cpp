/**
 * @file connection_traits_test.cpp
 * @author Marcus Edel
 *
 * Test the ConnectionTraits class. Because all of the values are known at
 * compile time, this test is meant to ensure that uses of ConnectionTraits
 * still compile okay and react as expected.
 *
 * This file is part of mlpack 2.0.0.
 *
 * mlpack is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * mlpack is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details (LICENSE.txt).
 *
 * You should have received a copy of the GNU General Public License along with
 * mlpack.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <mlpack/core.hpp>

#include <mlpack/methods/ann/connections/connection_traits.hpp>
#include <mlpack/methods/ann/connections/self_connection.hpp>
#include <mlpack/methods/ann/connections/fullself_connection.hpp>
#include <mlpack/methods/ann/layer/neuron_layer.hpp>
#include <mlpack/methods/ann/optimizer/irpropp.hpp>
#include <mlpack/methods/ann/init_rules/random_init.hpp>

#include <boost/test/unit_test.hpp>
#include "old_boost_test_definitions.hpp"

using namespace mlpack;
using namespace mlpack::ann;

BOOST_AUTO_TEST_SUITE(ConnectionTraitsTest);

// Be careful!  When writing new tests, always get the boolean value and store
// it in a temporary, because the Boost unit test macros do weird things and
// will cause bizarre problems.

// Test the defaults.
BOOST_AUTO_TEST_CASE(DefaultsTraitsTest)
{
  // An irrelevant non-connection type class is used here so that the default
  // implementation of ConnectionTraits is chosen.
  bool b = ConnectionTraits<int>::IsSelfConnection;
  BOOST_REQUIRE_EQUAL(b, false);

  b = ConnectionTraits<int>::IsFullselfConnection;
  BOOST_REQUIRE_EQUAL(b, false);
}

// Test the SelfConnection traits.
BOOST_AUTO_TEST_CASE(SelfConnectionTraitsTest)
{
  NeuronLayer<> recurrentLayer(1);
  NeuronLayer<> hiddenLayer(1);
  iRPROPp<> conOptimizer(1, 1);

  SelfConnection<
    decltype(recurrentLayer),
    decltype(hiddenLayer),
    decltype(conOptimizer)>
    layerCon(recurrentLayer, hiddenLayer, conOptimizer);

  bool b = ConnectionTraits<decltype(layerCon)>::IsSelfConnection;
  BOOST_REQUIRE_EQUAL(b, true);

  b = ConnectionTraits<decltype(layerCon)>::IsFullselfConnection;
  BOOST_REQUIRE_EQUAL(b, false);
}

// Test the FullselfConnection traits.
BOOST_AUTO_TEST_CASE(FullselfConnectionTraitsTest)
{
  NeuronLayer<> recurrentLayer(1);
  NeuronLayer<> hiddenLayer(1);
  iRPROPp<> conOptimizer(1, 1);

  FullselfConnection<
    decltype(recurrentLayer),
    decltype(hiddenLayer),
    decltype(conOptimizer)>
    layerCon(recurrentLayer, hiddenLayer, conOptimizer);

  bool b = ConnectionTraits<decltype(layerCon)>::IsSelfConnection;
  BOOST_REQUIRE_EQUAL(b, false);

  b = ConnectionTraits<decltype(layerCon)>::IsFullselfConnection;
  BOOST_REQUIRE_EQUAL(b, true);
}

BOOST_AUTO_TEST_SUITE_END();
