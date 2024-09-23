using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;

[TestFixture]
public class MapLogicManagerTests
{
    [Test]
    public void Should_Point_To_Correct_Index()
    {
		MapLogicManager manager = new MapLogicManager(10f, 0f);
		
        Assert.AreEqual(0f, manager.GetIndex(0f), "El index de 0 debería ser 0");
		Assert.AreEqual(0f, manager.GetIndex(1f), "El index de 1 debería ser 0");
		Assert.AreEqual(1f, manager.GetIndex(15f), "El index de 15 debería ser 1");
		Assert.AreEqual(-1f, manager.GetIndex(-0.5f), "El index de -0.5 debería ser -1");
		Assert.AreEqual(-1f, manager.GetIndex(-9f), "El index de -9 debería ser -1");
		Assert.AreEqual(-2f, manager.GetIndex(-11f), "El index de -11 debería ser -2");
		TestContext.Out.WriteLine("First test implemented");
    }
}
